import 'package:flutter/material.dart';
import '../model/welcome_content_model.dart';

class WelcomeContentSection extends StatelessWidget {
  final Animation<double> fade;
  final VoidCallback onTap;

  const WelcomeContentSection({
    super.key,
    required this.fade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: fade,
          child: Text(
            WelcomeContent.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeTransition(
          opacity: fade,
          child: Text(
            WelcomeContent.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
