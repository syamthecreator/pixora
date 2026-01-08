import 'package:flutter/material.dart';

class CameraGridOverlay extends StatelessWidget {
  final int divisions;
  final Color lineColor;
  final double lineWidth;
  final double opacity;

  const CameraGridOverlay({
    super.key,
    this.divisions = 3,
    this.lineColor = Colors.white,
    this.lineWidth = 0.6,
    this.opacity = 0.08,
  }) : assert(divisions > 1, 'Divisions must be greater than 1');

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        divisions: divisions,
        lineColor: lineColor,
        lineWidth: lineWidth,
        opacity: opacity,
      ),
      // Ensure it covers the entire available space
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int divisions;
  final Color lineColor;
  final double lineWidth;
  final double opacity;

  const _GridPainter({
    required this.divisions,
    required this.lineColor,
    required this.lineWidth,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _createPaint();
    final widthStep = size.width / divisions;
    final heightStep = size.height / divisions;

    _drawVerticalLines(canvas, size, paint, widthStep);
    _drawHorizontalLines(canvas, size, paint, heightStep);
  }

  Paint _createPaint() {
    return Paint()
      ..color = lineColor.withValues(alpha:  opacity)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
  }

  void _drawVerticalLines(Canvas canvas, Size size, Paint paint, double widthStep) {
    for (int i = 1; i < divisions; i++) {
      final x = widthStep * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawHorizontalLines(Canvas canvas, Size size, Paint paint, double heightStep) {
    for (int i = 1; i < divisions; i++) {
      final y = heightStep * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      divisions != oldDelegate.divisions ||
      lineColor != oldDelegate.lineColor ||
      lineWidth != oldDelegate.lineWidth ||
      opacity != oldDelegate.opacity;
}