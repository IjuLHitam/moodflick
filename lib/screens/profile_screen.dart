import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/supabase_service.dart';
import '../theme_provider.dart';
import '../widgets/glass_card.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = SupabaseService();

  Map<String, dynamic>? profile;
  int watchlistCount = 0;
  int historyCount = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    profile = await db.getProfile();
    watchlistCount = (await db.getWatchlists()).length;
    historyCount = (await db.getHistories()).length;

    if (mounted) setState(() {});
  }

  Future<void> editUsername() async {
    final controller = TextEditingController(
      text: profile?['username'] ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Username baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await db.updateUsername(result);
      await loadProfile();
    }
  }

  Future<void> logout() async {
    await db.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    if (db.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Kamu sedang masuk sebagai tamu'),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            GlassCard(
  padding: EdgeInsets.zero,
  radius: 28,
  color: const Color(0xFFE92D35).withValues(alpha: 0.88),
  child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE92D35),
          Color(0xFFFF6B6B),
        ],
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: profile == null
              ? const CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?['username'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile?['email'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
        ),
        IconButton(
          onPressed: editUsername,
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
      ],
    ),
  ),
),
            const SizedBox(height: 18),
            Row(
              children: [
                statBox('Watchlist', watchlistCount),
                const SizedBox(width: 12),
                statBox('Ditonton', historyCount),
              ],
            ),
            const SizedBox(height: 24),
            sectionTitle('Preferensi'),
            SwitchListTile(
              value: theme.isDark,
              onChanged: theme.toggleTheme,
              title: const Text('Mode Gelap'),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            sectionTitle('Akun'),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Ganti Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur ganti password bisa ditambahkan nanti'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFFE92D35),
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(color: Color(0xFFE92D35)),
              ),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget statBox(String label, int value) {
  return Expanded(
    child: GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 20,
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label),
        ],
      ),
    ),
  );
}

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}