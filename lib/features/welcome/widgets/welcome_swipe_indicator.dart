import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import '../model/welcome_content_model.dart';

class WelcomeSwipeIndicator extends StatelessWidget {
  final double dragOffset;
  final AnimationController controller;
  final Animation<double> arrowOpacity;

  static const double _maxDragDistance = 120.0;
  static const double _arrowDelayFactor = 0.2;

  const WelcomeSwipeIndicator({
    super.key,
    required this.dragOffset,
    required this.controller,
    required this.arrowOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: arrowOpacity,
      child: Transform.translate(
        offset: Offset(-dragOffset, 0),
        child: _buildSwipeRow(),
      ),
    );
  }

  // ───────────────────────── Layout ─────────────────────────

  Widget _buildSwipeRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_buildSwipeText(), const SizedBox(width: 8), _buildArrowRow()],
    );
  }

  // ───────────────────────── Text ─────────────────────────

  Widget _buildSwipeText() {
    final dragProgress = (dragOffset / _maxDragDistance).clamp(0.0, 1.0);

    return Opacity(
      opacity: 1.0 - dragProgress * 0.6,
      child: Text(WelcomeContent.swipeText, style: _textStyle),
    );
  }

  // ───────────────────────── Arrows ─────────────────────────

  Widget _buildArrowRow() {
    return Row(children: List.generate(3, _buildAnimatedArrow));
  }

  Widget _buildAnimatedArrow(int index) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return _buildArrowIcon(_arrowOpacityFor(index));
      },
    );
  }

  Widget _buildArrowIcon(double opacity) {
    return Opacity(
      opacity: opacity,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 1),
        child: Icon(Icons.arrow_back_ios, size: 18, color: AppColors.kWhiteColour),
      ),
    );
  }

  double _arrowOpacityFor(int index) {
    final delay = (2 - index) * _arrowDelayFactor;
    return (controller.value - delay).clamp(0.0, 1.0);
  }

  // ───────────────────────── Styles ─────────────────────────

  TextStyle get _textStyle => TextStyle(
    color: AppColors.kWhiteColour.withValues(alpha: 0.85),
    fontSize: 20,
    height: 1.0,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: AppColors.kPrimaryColour.withValues(alpha: 0.6),
        blurRadius: 12,
      ),
    ],
  );
}
