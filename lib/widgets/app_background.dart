import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF0B0B10),
                      Color(0xFF111116),
                      Color(0xFF16161F),
                    ]
                  : const [
                      Color(0xFFFFF7F7),
                      Color(0xFFF8F8FA),
                      Color(0xFFFFFFFF),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE92D35).withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE92D35).withValues(alpha: 0.18),
                  blurRadius: 90,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -90,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withValues(alpha: 0.10),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.10),
                  blurRadius: 90,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}