import 'dart:io';

import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final File file;

  const VideoThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white70, size: 30),
      ),
    );
  }
}
