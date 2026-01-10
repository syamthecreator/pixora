import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/gallery/models/media_type.dart';
import 'package:pixora/features/gallery/widgets/gallery_video_screen.dart';
import 'package:pixora/features/gallery/widgets/gallery_video_thumbnail.dart';
import 'package:provider/provider.dart';
import '../widgets/gallery_image_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GalleryController()..loadMedia(),
      child: const _GalleryView(),
    );
  }
}

class _GalleryView extends StatelessWidget {
  const _GalleryView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GalleryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: CupertinoPageScaffold(
        backgroundColor: Colors.black,
        navigationBar: const CupertinoNavigationBar(
          backgroundColor: Colors.black,
          middle: Text('Gallery', style: TextStyle(color: Colors.white)),
          previousPageTitle: 'Back',
        ),
        child: SafeArea(child: _buildBody(context, controller)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GalleryController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (controller.media.isEmpty) {
      return const Center(
        child: Text(
          'No images found',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
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
            final deleted = await Navigator.push<bool>(
              context,
              CupertinoPageRoute(
                builder: (_) => item.type == MediaType.image
                    ? GalleryImageScreen(mediaItem: item)
                    : GalleryVideoScreen(mediaItem: item),
              ),
            );

            if (deleted == true) {
              controller.loadMedia();
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
            : GalleryVideoThumbnail(file: item.file),

        if (item.type == MediaType.video)
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          ),
      ],
    );
  }
}
