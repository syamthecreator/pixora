import 'package:flutter/material.dart';

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
          backgroundColor: color.withValues(alpha: 0.18),
          onPressed: isDeleting ? null : onPressed,
          child: isDeleting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.delete, color: color),
        ),
      ),
    );
  }
}
