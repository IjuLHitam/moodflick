import 'package:flutter/material.dart';

class MoodCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  final Color lightColor1;
  final Color lightColor2;
  final Color darkColor1;
  final Color darkColor2;

  final VoidCallback onTap;
  final bool compact;
  final bool tall;

  const MoodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lightColor1,
    required this.lightColor2,
    required this.darkColor1,
    required this.darkColor2,
    required this.onTap,
    this.compact = true,
    this.tall = false,
  });

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bg1 = isLight ? widget.lightColor1 : widget.darkColor1;
    final bg2 = isLight ? widget.lightColor2 : widget.darkColor2;

    final titleSize = widget.compact ? 12.5 : 15.5;
    final subtitleSize = widget.compact ? 8.5 : 9.8;
    final iconBoxSize = widget.compact ? 24.0 : 30.0;
    final iconSize = widget.compact ? 13.0 : 16.0;
    final pad = widget.compact ? 9.0 : 13.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bg1, bg2],
            ),
            border: Border.all(
              color: isLight
                  ? Colors.white.withOpacity(0.45)
                  : Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? Colors.black.withOpacity(0.06)
                    : Colors.black.withOpacity(0.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                Positioned(
                  top: -16,
                  right: -12,
                  child: Container(
                    width: widget.tall ? 68 : 56,
                    height: widget.tall ? 68 : 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(
                        isLight ? 0.18 : 0.05,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -18,
                  left: -14,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(
                        isLight ? 0.025 : 0.07,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            isLight ? 0.25 : 0.08,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              isLight ? 0.45 : 0.10,
                            ),
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: iconSize,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}