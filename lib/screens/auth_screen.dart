import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'main_nav.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final service = SupabaseService();

  bool isLogin = true;
  bool loading = false;

  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  Future<void> submit() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      showMsg('Email dan password wajib diisi');
      return;
    }

    if (!isLogin && usernameC.text.isEmpty) {
      showMsg('Username wajib diisi');
      return;
    }

    if (passwordC.text.length < 6) {
      showMsg('Password minimal 6 karakter');
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        await service.signIn(
          email: emailC.text.trim(),
          password: passwordC.text.trim(),
        );
      } else {
        await service.signUp(
          username: usernameC.text.trim(),
          email: emailC.text.trim(),
          password: passwordC.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNav()),
      );
    } catch (e) {
      showMsg(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111116),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE92D35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.movie_creation_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text.rich(
                    TextSpan(
                      text: 'Mood',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Flick',
                          style: TextStyle(color: Color(0xFFE92D35)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: authTab('Masuk', isLogin),
                      ),
                      Expanded(
                        child: authTab('Daftar', !isLogin),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (!isLogin)
                    input(
                      controller: usernameC,
                      hint: 'Nama lengkap',
                      icon: Icons.person_outline,
                    ),
                  input(
                    controller: emailC,
                    hint: 'Alamat email',
                    icon: Icons.email_outlined,
                  ),
                  input(
                    controller: passwordC,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE92D35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const CircularProgressIndicator()
                          : Text(isLogin ? 'Masuk' : 'Buat Akun'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'atau',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: guestLogin,
                      child: const Text('Lanjut sebagai Tamu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget authTab(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = text == 'Masuk'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE92D35) : Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white12),
          ),
        ),
      ),
    );
  }
}