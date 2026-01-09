import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pixora/features/saved_images/controller/saved_images_controller.dart';

class ImageViewerScreen extends StatelessWidget {
  final File image;

  const ImageViewerScreen({
    super.key,
    required this.image,
  });

  Future<void> _deleteImage(
    BuildContext context,
    SavedImagesController controller,
  ) async {
    if (controller.isDeleting) return;

    // 🔔 Haptic feedback
    HapticFeedback.mediumImpact();

    final bool deleted =
        await controller.deleteImage(image);

    if (!context.mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image deleted'),
          duration: Duration(seconds: 2),
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
    final controller =
        context.watch<SavedImagesController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // -------- IMAGE --------
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(image),
            ),
          ),

          // -------- DELETE BUTTON --------
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor:
                    controller.isDeleting
                        ? Colors.grey
                        : Colors.red,
                onPressed: controller.isDeleting
                    ? null
                    : () =>
                        _deleteImage(context, controller),
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
