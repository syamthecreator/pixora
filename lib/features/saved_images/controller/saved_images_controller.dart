import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixora/core/platform/media_service.dart';

class SavedImagesController extends ChangeNotifier {
  /// 🔁 CHANGE THIS IF NEEDED
  final Directory imageDir =
      Directory('/storage/emulated/0/Pictures/Pixora');

  final List<File> images = [];

  bool isLoading = false;
  bool isDeleting = false;

  Future<void> loadImages() async {
    if (!imageDir.existsSync()) return;

    isLoading = true;
    notifyListeners();

    final files = imageDir
        .listSync()
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.png'),
        )
        .toList();

    files.sort(
      (a, b) =>
          b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );

    images
      ..clear()
      ..addAll(files);

    isLoading = false;
    notifyListeners();
  }

  /// 🔥 DELETE IMAGE (NO setState)
  Future<bool> deleteImage(File image) async {
    if (isDeleting) return false;

    isDeleting = true;
    notifyListeners();

    final bool deleted =
        await MediaDeleteService.deleteImage(image.path);

    if (deleted) {
      images.remove(image);
    }

    isDeleting = false;
    notifyListeners();

    return deleted;
  }
}
