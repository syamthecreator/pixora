import 'dart:io';
import 'media_type.dart';

class MediaItem {
  final File file;
  final MediaType type;

  MediaItem({
    required this.file,
    required this.type,
  });
}
