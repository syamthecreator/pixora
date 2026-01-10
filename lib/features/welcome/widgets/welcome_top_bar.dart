import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import '../model/welcome_content_model.dart';

class WelcomeTopBar extends StatelessWidget {
  final Animation<double> fade;

  const WelcomeTopBar({
    super.key,
    required this.fade,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitleSection(),
          _buildPageIndicators(),
        ],
      ),
    );
  }

  // ───────────────────────── Left Section ─────────────────────────

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoText(),
        const SizedBox(height: 4),
        Text(
          WelcomeContent.appTagline,
          style: _taglineStyle,
        ),
      ],
    );
  }

  Widget _buildLogoText() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'P', style: _logoHighlightStyle),
          TextSpan(text: 'IXORA', style: _logoTextStyle),
        ],
      ),
    );
  }

  // ───────────────────────── Right Section ─────────────────────────

  Widget _buildPageIndicators() {
    return Row(
      children: List.generate(3, _buildIndicatorDot),
    );
  }

  Widget _buildIndicatorDot(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(
          alpha: index == 1 ? 0.8 : 0.4,
        ),
      ),
    );
  }

  // ───────────────────────── Styles ─────────────────────────

  TextStyle get _logoHighlightStyle => const TextStyle(
        color: AppColors.neonCyan,
        fontSize: 18,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w700,
      );

  TextStyle get _logoTextStyle => TextStyle(
        color: AppColors.white.withValues(alpha: 0.85),
        fontSize: 18,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w600,
      );

  TextStyle get _taglineStyle => TextStyle(
        color: AppColors.white.withValues(alpha: 0.55),
        fontSize: 12,
        letterSpacing: 1.2,
      );
}
