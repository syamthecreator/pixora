import 'package:flutter/material.dart';
import '../model/welcome_content_model.dart';

class WelcomeTopBar extends StatelessWidget {
  final Animation<double> fade;

  const WelcomeTopBar({super.key, required this.fade});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WelcomeContent.appName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 18,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                WelcomeContent.appTagline,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Row(
            children: List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(left: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: i == 1 ? 0.8 : 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
