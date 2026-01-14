import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';

class DeleteFab extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onPressed;
  final Color color;

  const DeleteFab({
    super.key,
    required this.isDeleting,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: FloatingActionButton(
          backgroundColor: color.withValues(alpha: 0.25),
          onPressed: isDeleting ? null : onPressed,
          child: isDeleting
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.kRedColour),
                )
              : Icon(Icons.delete, color: color),
        ),
      ),
    );
  }
}
