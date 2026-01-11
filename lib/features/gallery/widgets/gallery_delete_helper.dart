import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/gallery_controller.dart';
import '../models/media_item.dart';

class GalleryDeleteHelper {
  static Future<bool> delete({
    required BuildContext context,
    required GalleryController controller,
    required MediaItem item,
    required Color snackbarColor,
  }) async {
    if (controller.isDeleting) return false;

    HapticFeedback.mediumImpact();

    final deleted = await controller.deleteMedia(item);
    if (!context.mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: snackbarColor.withValues(alpha:  0.2),
        content: Text(
          deleted ? 'Deleted' : 'Delete cancelled',
          style: TextStyle(color: snackbarColor),
        ),
      ),
    );

    return deleted;
  }
}
