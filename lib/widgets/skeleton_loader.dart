import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 16,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.25, end: 0.75).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: animation.value * 0.16)
                : Colors.black.withValues(alpha: animation.value * 0.12),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

class MovieCardSkeleton extends StatelessWidget {
  const MovieCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final cardWidth = isDesktop ? 130.0 : 112.0;

    return SizedBox(
      width: cardWidth,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              radius: 18,
            ),
          ),
          SizedBox(height: 8),
          SkeletonBox(width: 90, height: 12, radius: 8),
          SizedBox(height: 6),
          SkeletonBox(width: 55, height: 10, radius: 8),
        ],
      ),
    );
  }
}

class MovieGridSkeleton extends StatelessWidget {
  const MovieGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: 12,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 8 : 3,
        mainAxisExtent: isDesktop ? 205 : 185,
        crossAxisSpacing: isDesktop ? 12 : 10,
        mainAxisSpacing: isDesktop ? 18 : 14,
      ),
      itemBuilder: (context, index) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: double.infinity,
                radius: 14,
              ),
            ),
            SizedBox(height: 8),
            SkeletonBox(width: 80, height: 11, radius: 8),
            SizedBox(height: 5),
            SkeletonBox(width: 45, height: 9, radius: 8),
          ],
        );
      },
    );
  }
}