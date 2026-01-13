import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
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
        _fadeText(text: WelcomeContent.title, style: _titleStyle),
        const SizedBox(height: 12),
        _fadeText(text: WelcomeContent.subtitle, style: _subtitleStyle),
        const SizedBox(height: 32),
      ],
    );
  }

  // ───────────────────────── Helpers ─────────────────────────

  Widget _fadeText({required String text, required TextStyle style}) {
    return FadeTransition(
      opacity: fade,
      child: Text(text, style: style),
    );
  }

  // ───────────────────────── Styles ─────────────────────────

  TextStyle get _titleStyle => const TextStyle(
    color: AppColors.kWhiteColour,
    fontSize: 34,
    fontWeight: FontWeight.w600,
  );

  TextStyle get _subtitleStyle => TextStyle(
    color: AppColors.kWhiteColour.withValues(alpha: 0.7),
    fontSize: 15,
    height: 1.4,
  );
}
