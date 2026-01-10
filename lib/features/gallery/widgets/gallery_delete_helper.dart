import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/gallery/models/media_type.dart';

class GalleryDeleteHelper {
  static Future<void> delete({
    required BuildContext context,
    required GalleryController controller,
    required MediaItem item,
    required Color snackbarColor,
  }) async {
    if (controller.isDeleting) return;

    HapticFeedback.mediumImpact();

    final deleted = await controller.deleteMedia(item);
    if (!context.mounted) return;

    _showSnackBar(
      context,
      deleted
          ? item.type == MediaType.image
              ? 'Image deleted'
              : 'Video deleted'
          : 'Delete cancelled',
      snackbarColor,
    );

    if (deleted) {
      Navigator.pop(context, true);
    }
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color.withValues(alpha: 0.18),
        content: Text(message, style: TextStyle(color: color)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
