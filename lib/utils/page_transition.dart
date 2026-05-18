import 'package:flutter/material.dart';

Route createFadeSlideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.08, 0.04),
        end: Offset.zero,
      ).animate(curved);

      final fadeAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(curved);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: child,
        ),
      );
    },
  );
}