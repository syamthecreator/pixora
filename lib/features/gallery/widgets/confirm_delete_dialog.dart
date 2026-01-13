import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;

  const ConfirmDeleteDialog({
    super.key,
    this.title = 'Delete',
    this.message = 'Are you sure you want to delete this item?',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // backgroundColor: AppColors.kWhiteColour.withValues(alpha: 0.18),
      title: Text(title, style: TextStyle(color: AppColors.kPrimaryColour)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.kWhiteColour),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withValues(alpha: 0.25),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
