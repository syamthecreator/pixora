import 'dart:io';

enum MediaType { image, video }

class MediaItem {
  final File file;
  final MediaType type;

  MediaItem({required this.file, required this.type});
}
