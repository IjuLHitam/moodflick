import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_screen.dart';
import 'main_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  final List<OnboardingData> pages = const [
    OnboardingData(
      icon: '🎭',
      title: 'Temukan Film\nSesuai Mood',
      description:
          'MoodFlick membantumu menemukan film yang cocok dengan suasana hatimu hari ini.',
      color1: Color(0xFFFF3B3B),
      color2: Color(0xFFB80000),
      glowColor: Color(0xFFFF3B3B),
    ),
    OnboardingData(
      icon: '⚡',
      title: 'Tiga Langkah\nke Film Terbaik',
      description:
          'Pilih mood → lihat rekomendasi → mulai nonton. Sesederhana itu.',
      color1: Color(0xFFFF7A3D),
      color2: Color(0xFFE92D35),
      glowColor: Color(0xFFFF5A3D),
    ),
    OnboardingData(
      icon: '🌟',
      title: 'Koleksi Film\nTerlengkap',
      description:
          'Jutaan film dari berbagai genre. Watchlist dan riwayat tontonanmu tersimpan aman.',
      color1: Color(0xFFB347D9),
      color2: Color(0xFF5B7CFA),
      glowColor: Color(0xFF9B5DE5),
    ),
  ];

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);

    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: user == null ? const AuthScreen() : const MainNav(),
          );
        },
      ),
    );
  }

  void nextPage() {
    if (currentIndex == pages.length - 1) {
      finishOnboarding();
    } else {
      controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget buildNeonBackground(OnboardingData page) {
    return Positioned.fill(
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF090A12),
                  Color(0xFF05060C),
                  Color(0xFF030309),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Glow halus bagian atas
          Positioned(
            top: -230,
            left: -90,
            right: -90,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500),
                boxShadow: [
                  BoxShadow(
                    color: page.color1.withOpacity(0.08),
                    blurRadius: 180,
                    spreadRadius: 36,
                  ),
                ],
              ),
            ),
          ),

          // Glow lembut di tengah
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: page.glowColor.withOpacity(0.10),
                      blurRadius: 130,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Glow kiri sangat tipis
          Positioned(
            left: -130,
            top: 260,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              width: 180,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                boxShadow: [
                  BoxShadow(
                    color: page.color1.withOpacity(0.045),
                    blurRadius: 130,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // Glow kanan sangat tipis
          Positioned(
            right: -130,
            top: 220,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              width: 180,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                boxShadow: [
                  BoxShadow(
                    color: page.color2.withOpacity(0.045),
                    blurRadius: 130,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // Glow bawah mengikuti warna tombol
          Positioned(
            left: 24,
            right: 24,
            bottom: 4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: page.color1.withOpacity(0.13),
                    blurRadius: 34,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: page.color2.withOpacity(0.08),
                    blurRadius: 56,
                    spreadRadius: 1,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = pages[currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          buildNeonBackground(currentPage),

          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 24,
                  child: TextButton(
                    onPressed: finishOnboarding,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                PageView.builder(
                  controller: controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  page.color1,
                                  page.color2,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.glowColor.withOpacity(0.20),
                                  blurRadius: 30,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                page.icon,
                                style: const TextStyle(fontSize: 46),
                              ),
                            ),
                          ),

                          const SizedBox(height: 42),

                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                              letterSpacing: -0.7,
                            ),
                          ),

                          const SizedBox(height: 22),

                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.76),
                                fontSize: 16,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const Spacer(flex: 3),
                        ],
                      ),
                    );
                  },
                ),

                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 26,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) {
                            final active = currentIndex == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 26 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: active
                                    ? currentPage.color1
                                    : Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  currentPage.color1,
                                  currentPage.color2,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      currentPage.glowColor.withOpacity(0.22),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentIndex == pages.length - 1
                                        ? 'Mulai Sekarang'
                                        : 'Lanjut',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String icon;
  final String title;
  final String description;
  final Color color1;
  final Color color2;
  final Color glowColor;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color1,
    required this.color2,
    required this.glowColor,
  });
}