import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixora/core/constants/app_directory.dart';
import 'package:pixora/core/platform/media_service.dart';
import 'package:pixora/features/gallery/models/media_type.dart';

class GalleryController extends ChangeNotifier {
  final Directory imageDir = Directory(DirectoryView.imageDir);
  final Directory videoDir = Directory(DirectoryView.videoDir);
  final List<MediaItem> media = [];

  bool isLoading = false;
  bool isDeleting = false;

  Future<void> loadMedia() async {
    isLoading = true;
    notifyListeners();

    final List<MediaItem> items = [];

    if (imageDir.existsSync()) {
      final images = imageDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .map((f) => MediaItem(file: f, type: MediaType.image));
      items.addAll(images);
    }

    if (videoDir.existsSync()) {
      final videos = videoDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.mp4') || f.path.endsWith('.mov'))
          .map((f) => MediaItem(file: f, type: MediaType.video));
      items.addAll(videos);
    }

    items.sort(
      (a, b) => b.file.lastModifiedSync().compareTo(a.file.lastModifiedSync()),
    );

    media
      ..clear()
      ..addAll(items);

    isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteMedia(MediaItem item) async {
    if (isDeleting) return false;

    isDeleting = true;
    notifyListeners();

    final deleted = await MediaDeleteService.deleteImage(item.file.path);

    if (deleted) {
      media.remove(item);
    }

    isDeleting = false;
    notifyListeners();
    return deleted;
  }
}
