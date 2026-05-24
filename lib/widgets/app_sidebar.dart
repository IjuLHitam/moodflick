import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme_provider.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final user = Supabase.instance.client.auth.currentUser;

    final name = user?.userMetadata?['username'] ??
        user?.email?.split('@').first ??
        'guest';

    final email = user?.email ?? 'guest@moodflick.app';

    return Container(
      width: 232,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111116)
            : Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE92D35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.movie_creation_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MoodFlick',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          'Film sesuai mood kamu',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Divider(color: Colors.grey.withValues(alpha: 0.18)),

            sidebarItem(
              context,
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Beranda',
            ),
            sidebarItem(
              context,
              index: 1,
              icon: Icons.search_rounded,
              activeIcon: Icons.search_rounded,
              label: 'Cari Film',
            ),
            sidebarItem(
              context,
              index: 2,
              icon: Icons.bookmark_border_rounded,
              activeIcon: Icons.bookmark_rounded,
              label: 'Watchlist',
            ),
            sidebarItem(
              context,
              index: 3,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profil',
            ),

            const Spacer(),

            Divider(color: Colors.grey.withValues(alpha: 0.18)),

            SwitchListTile(
              value: theme.isDark,
              onChanged: theme.toggleTheme,
              title: const Text(
                'Mode Gelap',
                style: TextStyle(fontSize: 13),
              ),
              secondary: const Icon(Icons.dark_mode_outlined, size: 20),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE92D35),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'G',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'MoodFlick v1.0 • Powered by TMDB',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget sidebarItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final active = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => onSelected(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE92D35).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                active ? activeIcon : icon,
                color: active ? const Color(0xFFE92D35) : null,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active ? const Color(0xFFE92D35) : null,
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE92D35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}