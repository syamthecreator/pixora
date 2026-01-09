import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixora/features/saved_images/controller/saved_images_controller.dart';
import 'package:provider/provider.dart';
import '../widgets/image_viewer_screen.dart';

class SavedImagesScreen extends StatelessWidget {
  const SavedImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedImagesController()..loadImages(),
      child: const _SavedImagesView(),
    );
  }
}

class _SavedImagesView extends StatelessWidget {
  const _SavedImagesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SavedImagesController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Gallery'),
      ),
      body: _buildBody(context, controller),
    );
  }

  Widget _buildBody(BuildContext context, SavedImagesController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (controller.images.isEmpty) {
      return const Center(
        child: Text('No images found', style: TextStyle(color: Colors.white70)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: controller.images.length,
      itemBuilder: (_, index) {
        final File image = controller.images[index];

        return GestureDetector(
          onTap: () async {
            final bool? deleted = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageViewerScreen(image: image),
              ),
            );
            if (!context.mounted) return;
            if (deleted == true) {
              context.read<SavedImagesController>().loadImages();
            }
          },

          child: Image.file(image, fit: BoxFit.cover),
        );
      },
    );
  }
}
