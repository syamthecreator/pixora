import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/gallery/models/media_type.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const VideoPlayerScreen({super.key, required this.mediaItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.mediaItem.file)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    // ▶️ Video finished → go back
    if (!_hasPopped && position >= duration) {
      _hasPopped = true;
      Navigator.pop(context, false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  // ---------- DELETE (SAME AS IMAGE VIEWER) ----------
  Future<void> _deleteMedia(
    BuildContext context,
    GalleryController controller,
    MediaItem item,
  ) async {
    if (controller.isDeleting) return;

    HapticFeedback.mediumImpact();

    final bool deleted = await controller.deleteMedia(item);

    if (!context.mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video deleted'),
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
    final savedController = context.watch<GalleryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Stack(
        children: [
          // -------- VIDEO --------
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          // -------- DELETE BUTTON --------
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: savedController.isDeleting
                    ? Colors.grey
                    : Colors.red,
                onPressed: savedController.isDeleting
                    ? null
                    : () => _deleteMedia(
                        context,
                        savedController,
                        widget.mediaItem,
                      ),
                child: savedController.isDeleting
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
