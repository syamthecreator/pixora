import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';

class DotLoader extends StatefulWidget {
  final double dotSize;
  final double spacing;

  const DotLoader({super.key, this.dotSize = 8, this.spacing = 6});

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final progress = (_controller.value + index * 0.2) % 1.0;
        final scale = 0.6 + (progress < 0.5 ? progress : 1 - progress);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kAccentYellow,
              boxShadow: [
                BoxShadow(
                  color: AppColors.kAccentYellow.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: _dot(i),
        ),
      ),
    );
  }
}
