import 'package:flutter/material.dart';
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
  static const double _maxDragDistance = 120.0;
  static const double _completionThreshold = 0.75;

  double _dragOffset = 0.0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Right → Left swipe increases offset
      _dragOffset =
          (_dragOffset - details.delta.dx).clamp(0.0, _maxDragDistance);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final bool isComplete =
        _dragOffset > _maxDragDistance * _completionThreshold;

    if (isComplete) {
      widget.onCompleted();
    } else {
      _resetDragOffset();
    }
  }

  void _resetDragOffset() {
    setState(() => _dragOffset = 0.0);
  }

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

  /// 🔥 TEXT + ARROWS IN SAME LINE
  Widget _buildSwipeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSwipeText(),
        const SizedBox(width: 8),
        _buildArrowRow(),
      ],
    );
  }

  Widget _buildSwipeText() {
    return FadeTransition(
      opacity: _createTextOpacityAnimation(),
      child: Text(
        WelcomeContent.swipeText,
        style: _textStyle,
      ),
    );
  }

  Widget _buildArrowRow() {
    return Row(
      children: List.generate(3, _buildAnimatedArrow),
    );
  }

  Widget _buildAnimatedArrow(int index) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final opacity = _calculateArrowOpacity(index);
        return _buildArrowIcon(opacity);
      },
    );
  }

  Widget _buildArrowIcon(double opacity) {
    return Opacity(
      opacity: opacity,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.arrow_back_ios,
          size: 14,
          color: Colors.white70,
        ),
      ),
    );
  }

  // Animations
  Animation<double> _createTextOpacityAnimation() {
    return Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  double _calculateArrowOpacity(int index) {
    const double delayFactor = 0.2;
    final double delay = (2 - index) * delayFactor;
    return (widget.controller.value - delay).clamp(0.0, 1.0);
  }

  // Styles
  TextStyle get _textStyle => const TextStyle(
        color: Colors.white,
        fontSize: 14,
        letterSpacing: 1,
      );
}
