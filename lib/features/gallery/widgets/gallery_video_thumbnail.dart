import 'dart:io';

import 'package:flutter/material.dart';

class GalleryVideoThumbnail extends StatelessWidget {
  final File file;

  const GalleryVideoThumbnail({super.key, required this.file});

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
