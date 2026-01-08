import 'dart:ui';
import 'package:flutter/material.dart';

class CameraOverlayWidget extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  final VoidCallback? onTap;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final double blurSigma;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final int? divisions;
  final Color lineColor;
  final double lineWidth;
  final double opacity;
  final CameraOverlayType type;

  const CameraOverlayWidget._({
    super.key,
    this.child,
    this.icon,
    this.onTap,
    this.size = 18.0,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.blurSigma = 14.0,
    this.borderRadius = 20.0,
    this.padding = EdgeInsets.zero,
    this.divisions,
    this.lineColor = Colors.white,
    this.lineWidth = 0.6,
    this.opacity = 0.08,
    required this.type,
  });

  factory CameraOverlayWidget.glassContainer({
    Key? key,
    required Widget child,
    double borderRadius = 20.0,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Color backgroundColor = Colors.black,
    double blurSigma = 14.0,
  }) {
    return CameraOverlayWidget._(
      key: key,
      borderRadius: borderRadius,
      padding: padding,
      backgroundColor: backgroundColor,
      blurSigma: blurSigma,
      type: CameraOverlayType.glassContainer,
      child: child,
    );
  }

  factory CameraOverlayWidget.glassIcon({
    Key? key,
    required IconData icon,
    VoidCallback? onTap,
    double size = 18.0,
    Color iconColor = Colors.white,
    Color backgroundColor = Colors.black,
    double blurSigma = 14.0,
  }) {
    return CameraOverlayWidget._(
      key: key,
      icon: icon,
      onTap: onTap,
      size: size,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      blurSigma: blurSigma,
      borderRadius: 50.0,
      padding: const EdgeInsets.all(10),
      type: CameraOverlayType.glassIcon,
    );
  }

  factory CameraOverlayWidget.gridOverlay({
    Key? key,
    int divisions = 3,
    Color lineColor = Colors.white,
    double lineWidth = 0.6,
    double opacity = 0.08,
  }) {
    assert(divisions > 1, 'Divisions must be greater than 1');
    return CameraOverlayWidget._(
      key: key,
      divisions: divisions,
      lineColor: lineColor,
      lineWidth: lineWidth,
      opacity: opacity,
      type: CameraOverlayType.gridOverlay,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CameraOverlayType.glassContainer:
        return _buildGlassContainer();
      case CameraOverlayType.glassIcon:
        return _buildGlassIcon();
      case CameraOverlayType.gridOverlay:
        return _buildGridOverlay();
    }
  }

  Widget _buildGlassContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          child: child!,
        ),
      ),
    );
  }

  Widget _buildGlassIcon() {
    return GestureDetector(
      onTap: onTap,
      child: CameraOverlayWidget.glassContainer(
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        blurSigma: blurSigma,
        padding: padding,
        child: Icon(icon!, size: size, color: iconColor),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(
        divisions: divisions!,
        lineColor: lineColor,
        lineWidth: lineWidth,
        opacity: opacity,
      ),
    );
  }
}

enum CameraOverlayType { glassContainer, glassIcon, gridOverlay }

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
    final paint = Paint()
      ..color = lineColor.withValues(alpha: opacity)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final widthStep = size.width / divisions;
    final heightStep = size.height / divisions;

    for (int i = 1; i < divisions; i++) {
      final x = widthStep * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      final y = heightStep * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return divisions != oldDelegate.divisions ||
        lineColor != oldDelegate.lineColor ||
        lineWidth != oldDelegate.lineWidth ||
        opacity != oldDelegate.opacity;
  }

  @override
  bool shouldRebuildSemantics(_GridPainter oldDelegate) => false;
}
