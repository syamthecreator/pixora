import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';

import '../models/camera_mode.dart';

class CameraModeButton extends StatelessWidget {
  final CameraMode mode;
  final bool isActive;
  final VoidCallback onTap;

  const CameraModeButton({
    super.key,
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _animationDuration,
        padding: _contentPadding,
        decoration: _buildDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mode.icon, size: _iconSize, color: _getIconColor()),
            const SizedBox(width: 6),
            Text(mode.label, style: _getTextStyle()),
          ],
        ),
      ),
    );
  }

  // Helper methods
  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: isActive
          ? AppColors.kPrimaryColour.withValues(alpha: 0.18)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    );
  }

  Color _getIconColor() {
    return isActive ? AppColors.kPrimaryColour : Colors.white54;
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: _getIconColor(),
    );
  }

  // Constants
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const EdgeInsets _contentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  );
  static const double _iconSize = 16;
}
