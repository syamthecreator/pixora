import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
class SplashLogo extends StatelessWidget {
  final Animation<double> scale;
  final Animation<double> rotation;
  final String logoUrl;

  const SplashLogo({
    super.key,
    required this.scale,
    required this.rotation,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating neon ring
        Transform.rotate(
          angle: rotation.value,
          child: Container(
            width: 170,
            height: 170,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  AppColors.neonCyan,
                  AppColors.electricBlue,
                  AppColors.neonPurple,
                  AppColors.neonCyan,
                ],
              ),
            ),
          ),
        ),

        // Inner glowing circle + logo
        Transform.scale(
          scale: scale.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonCyan,
                  AppColors.neonPurple,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Image.asset(
                logoUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
