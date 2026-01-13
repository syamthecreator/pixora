import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';

enum CameraOverlayType { glassContainer, glassIcon }

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
  final CameraOverlayType type;

  const CameraOverlayWidget._({
    super.key,
    this.child,
    this.icon,
    this.onTap,
    this.size = 18.0,
    this.iconColor = Colors.white,
    this.backgroundColor = AppColors.kSecondaryColour,
    this.blurSigma = 14.0,
    this.borderRadius = 20.0,
    this.padding = EdgeInsets.zero,
    required this.type,
  });

  factory CameraOverlayWidget.glassContainer({
    Key? key,
    required Widget child,
    double borderRadius = 20.0,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Color backgroundColor = AppColors.kSecondaryColour,
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
    Color iconColor = AppColors.kWhiteColour,
    Color backgroundColor = AppColors.kSecondaryColour,
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

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CameraOverlayType.glassContainer:
        return _buildGlassContainer();
      case CameraOverlayType.glassIcon:
        return _buildGlassIcon();
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
}
