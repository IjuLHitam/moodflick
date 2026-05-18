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
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: SkeletonBox(
              width: 130,
              height: double.infinity,
              radius: 18,
            ),
          ),
          SizedBox(height: 8),
          SkeletonBox(width: 110, height: 12, radius: 8),
          SizedBox(height: 6),
          SkeletonBox(width: 60, height: 10, radius: 8),
        ],
      ),
    );
  }
}

class MovieGridSkeleton extends StatelessWidget {
  const MovieGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: double.infinity,
                radius: 18,
              ),
            ),
            SizedBox(height: 8),
            SkeletonBox(width: 120, height: 12, radius: 8),
            SizedBox(height: 6),
            SkeletonBox(width: 70, height: 10, radius: 8),
          ],
        );
      },
    );
  }
}