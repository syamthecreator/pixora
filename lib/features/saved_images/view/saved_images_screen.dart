import 'package:flutter/material.dart';
import 'package:pixora/features/saved_images/controller/saved_images_controller.dart';
import 'package:pixora/features/saved_images/models/media_type.dart';
import 'package:pixora/features/saved_images/widgets/video_playing_screen.dart';
import 'package:pixora/features/saved_images/widgets/video_thumbnail.dart';
import 'package:provider/provider.dart';
import '../widgets/image_viewer_screen.dart';

class SavedMediaScreen extends StatelessWidget {
  const SavedMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedImagesController()..loadMedia(),
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

    if (controller.media.isEmpty) {
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
      itemCount: controller.media.length,
      itemBuilder: (_, index) {
        final item = controller.media[index];

        return GestureDetector(
          onTap: () async {
            if (item.type == MediaType.image) {
              final deleted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageViewerScreen(mediaItem: item),
                ),
              );

              if (deleted == true) {
                controller.loadMedia();
              }
            } else {
              final deleted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(mediaItem: item),
                ),
              );

              if (deleted == true) {
                controller.loadMedia();
              }
            }
          },

          child: _MediaTile(item: item),
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  final MediaItem item;

  const _MediaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        item.type == MediaType.image
            ? Image.file(item.file, fit: BoxFit.cover)
            :
             VideoThumbnail(file: item.file),

        if (item.type == MediaType.video)
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          ),
      ],
    );
  }
}
