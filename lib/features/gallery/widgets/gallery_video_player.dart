import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../controller/gallery_controller.dart';

class GalleryVideoPlayer extends StatefulWidget {
  final File file;

  const GalleryVideoPlayer({super.key, required this.file});

  @override
  State<GalleryVideoPlayer> createState() => _GalleryVideoPlayerState();
}

class _GalleryVideoPlayerState extends State<GalleryVideoPlayer> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (!mounted) return;

        context.read<GalleryController>().setVideoPlaying(true); // ✅ FIX
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    final galleryController = context.read<GalleryController>();

    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying) {
      galleryController.onVideoCompleted();
      _controller.seekTo(Duration.zero);
    }
  }

  void _togglePlayback(GalleryController galleryController) {
    galleryController.toggleVideoPlayback();

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryController = context.watch<GalleryController>();

    if (!_controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.kPrimaryColour,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _togglePlayback(galleryController),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // ▶️ SHOW ICON WHEN PAUSED OR COMPLETED
          if (!galleryController.isVideoPlaying)
            Container(
              decoration:  BoxDecoration(
                color: AppColors.kSecondaryColour,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.kWhiteColour,
                size: 60,
              ),
            ),
        ],
      ),
    );
  }
}
