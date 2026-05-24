import 'package:flutter/material.dart';

import '../widgets/app_sidebar.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    SearchScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                AppSidebar(
                  selectedIndex: index,
                  onSelected: (value) {
                    setState(() => index = value);
                  },
                ),
                Expanded(
                  child: pages[index],
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: pages[index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) {
              setState(() => index = value);
            },
            indicatorColor: const Color(0xFFE92D35).withValues(alpha: 0.15),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: Color(0xFFE92D35)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search, color: Color(0xFFE92D35)),
                label: 'Cari',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark, color: Color(0xFFE92D35)),
                label: 'Watchlist',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: Color(0xFFE92D35)),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}