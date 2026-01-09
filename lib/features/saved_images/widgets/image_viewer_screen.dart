import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/features/saved_images/models/media_type.dart';
import 'package:provider/provider.dart';
import 'package:pixora/features/saved_images/controller/saved_images_controller.dart';

class ImageViewerScreen extends StatelessWidget {
  final MediaItem mediaItem;

  const ImageViewerScreen({
    super.key,
    required this.mediaItem,
  });

  Future<void> _deleteMedia(
    BuildContext context,
    SavedImagesController controller,
    MediaItem item,
  ) async {
    if (controller.isDeleting) return;

    // 🔔 Haptic feedback
    HapticFeedback.mediumImpact();

    final bool deleted = await controller.deleteMedia(item);

    if (!context.mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item.type == MediaType.image ? 'Image deleted' : 'Video deleted',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete cancelled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SavedImagesController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(mediaItem.file),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: controller.isDeleting
                    ? Colors.grey
                    : Colors.red,
                onPressed: controller.isDeleting
                    ? null
                    : () => _deleteMedia(context, controller, mediaItem),
                child: controller.isDeleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
