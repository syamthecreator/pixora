import 'package:flutter/material.dart';
import '../models/splash_brand_model.dart';

class SplashText extends StatelessWidget {
  final SplashBrandModel brand;

  const SplashText({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          brand.title,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          brand.subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
