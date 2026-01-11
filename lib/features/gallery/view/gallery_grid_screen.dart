import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/gallery_controller.dart';
import '../models/media_type.dart';
import '../widgets/gallery_video_thumbnail.dart';
import 'gallery_viewer_screen.dart';

class GalleryGridScreen extends StatelessWidget {
  const GalleryGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GalleryController()..loadMedia(),
      child: const _GalleryGridView(),
    );
  }
}

class _GalleryGridView extends StatelessWidget {
  const _GalleryGridView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GalleryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Gallery'),
      ),

   body: controller.isLoading
    ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
    : controller.media.isEmpty
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
                SizedBox(height: 12),
                Text(
                  'No media found',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(6),
            itemCount: controller.media.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (_, index) {
              final item = controller.media[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<GalleryController>(),
                        child: GalleryViewerScreen(
                          initialIndex: index,
                        ),
                      ),
                    ),
                  );
                },
                child: item.type == MediaType.image
                    ? Image.file(item.file, fit: BoxFit.cover)
                    : GalleryVideoThumbnail(file: item.file),
              );
            },
          ),

    );
  }
}
