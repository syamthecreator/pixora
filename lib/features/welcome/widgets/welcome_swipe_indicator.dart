import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import '../model/welcome_content_model.dart';

class WelcomeSwipeIndicator extends StatefulWidget {
  final AnimationController controller;
  final Animation<double> arrowOpacity;
  final VoidCallback onCompleted;

  const WelcomeSwipeIndicator({
    super.key,
    required this.controller,
    required this.arrowOpacity,
    required this.onCompleted,
  });

  @override
  State<WelcomeSwipeIndicator> createState() => _WelcomeSwipeIndicatorState();
}

class _WelcomeSwipeIndicatorState extends State<WelcomeSwipeIndicator> {
  // Constants
  static const double _maxDragDistance = 120.0;
  static const double _completionThreshold = 0.75;
  static const double _arrowDelayFactor = 0.2;

  double _dragOffset = 0.0;

  // ───────────────────────── Gestures ─────────────────────────

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dx).clamp(
        0.0,
        _maxDragDistance,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final isComplete = _dragOffset > _maxDragDistance * _completionThreshold;

    isComplete ? widget.onCompleted() : _resetDragOffset();
  }

  void _resetDragOffset() {
    setState(() => _dragOffset = 0.0);
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.arrowOpacity,
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Transform.translate(
          offset: Offset(-_dragOffset, 0),
          child: _buildSwipeRow(),
        ),
      ),
    );
  }

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
    final dragProgress = (_dragOffset / _maxDragDistance).clamp(0.0, 1.0);

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
      animation: widget.controller,
      builder: (_, __) {
        return _buildArrowIcon(_arrowOpacityFor(index));
      },
    );
  }

  Widget _buildArrowIcon(double opacity) {
    return Opacity(
      opacity: opacity,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 1),
        child: Icon(Icons.arrow_back_ios, size: 18, color: AppColors.white),
      ),
    );
  }

  double _arrowOpacityFor(int index) {
    final delay = (2 - index) * _arrowDelayFactor;
    return (widget.controller.value - delay).clamp(0.0, 1.0);
  }

  // ───────────────────────── Styles ─────────────────────────

  TextStyle get _textStyle => TextStyle(
    color: AppColors.white.withValues(alpha: 0.85),
    fontSize: 20,
    height: 1.0,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: AppColors.neonPurple.withValues(alpha: 0.6),
        blurRadius: 12,
      ),
    ],
  );
}
