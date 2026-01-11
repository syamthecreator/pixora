import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GalleryVideoThumbnail extends StatefulWidget {
  final File file;

  const GalleryVideoThumbnail({super.key, required this.file});

  @override
  State<GalleryVideoThumbnail> createState() => _GalleryVideoThumbnailState();
}

class _GalleryVideoThumbnailState extends State<GalleryVideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.pause(); // 🔥 DO NOT PLAY
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.videocam, color: Colors.white70),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),

        // ▶️ Play icon overlay
        const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 36,
          ),
        ),
      ],
    );
  }
}
