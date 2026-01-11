import 'package:flutter/material.dart';
import 'package:pixora/features/gallery/widgets/gallery_video_player.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';

class MediaPage extends StatelessWidget {
  final MediaItem item;

  const MediaPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.type == MediaType.image) {
      return Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.file(item.file),
        ),
      );
    }

    return GalleryVideoPlayer(file: item.file);
  }
}
