import 'package:flutter/material.dart';
import 'package:pixora/core/constants/app_images.dart';

class WelcomeBackground extends StatelessWidget {
  final Animation<double> fade;
  final Animation<double> scale;

  const WelcomeBackground({
    super.key,
    required this.fade,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Image.asset(
          AppImages.girl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
