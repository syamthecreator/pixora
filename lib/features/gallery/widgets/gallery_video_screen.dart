import 'package:flutter/material.dart';
import 'package:pixora/features/gallery/widgets/delete_fab.dart';
import 'package:pixora/features/gallery/widgets/gallery_delete_helper.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/gallery/models/media_type.dart';

class GalleryVideoScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const GalleryVideoScreen({super.key, required this.mediaItem});

  @override
  State<GalleryVideoScreen> createState() => _GalleryVideoScreenState();
}

class _GalleryVideoScreenState extends State<GalleryVideoScreen> {
  late final VideoPlayerController _videoController;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(widget.mediaItem.file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.play();
        }
      })
      ..addListener(_videoListener);
  }

  void _videoListener() {
    final value = _videoController.value;
    if (!_hasPopped &&
        value.isInitialized &&
        value.position >= value.duration) {
      _hasPopped = true;
      Navigator.pop(context, false);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GalleryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Stack(
        children: [
          Center(
            child: _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          DeleteFab(
            isDeleting: controller.isDeleting,
            color: Colors.red,
            onPressed: () => GalleryDeleteHelper.delete(
              context: context,
              controller: controller,
              item: widget.mediaItem,
              snackbarColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
