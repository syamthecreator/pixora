import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';

class DirectoryView {
  static const String imageDir = '/storage/emulated/0/Pictures/Pixora';
  static const String videoDir = '/storage/emulated/0/Movies/Pixora';
}

class GalleryController extends ChangeNotifier {
  final List<MediaItem> _media = [];

  bool _isLoading = false;
  bool _isDeleting = false;

  bool _isVideoPlaying = true;

  List<MediaItem> get media => _media;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  bool get isVideoPlaying => _isVideoPlaying;

  // ==========================================================
  // 🚀 FAST ASYNC MEDIA LOADER (NO UI BLOCKING)
  // ==========================================================

 Future<void> loadMedia() async {
  if (_isLoading) {
    debugPrint("⏸️ Gallery already loading, skipping");
    return;
  }

  debugPrint("🔄 Gallery load started");

  _isLoading = true;
  notifyListeners();

  _media.clear();

  try {
    final List<_MediaWithTime> temp = [];

    // 📸 IMAGES
    final imageDir = Directory(DirectoryView.imageDir);
    debugPrint("📂 Checking image dir: ${imageDir.path}");

    if (await imageDir.exists()) {
      await for (final entity in imageDir.list(followLinks: false)) {
        if (entity is File && _isImage(entity.path)) {
          final stat = await entity.stat();

          debugPrint("🖼️ Found image: ${entity.path}");

          temp.add(
            _MediaWithTime(
              item: MediaItem(file: entity, type: MediaType.image),
              time: stat.modified,
            ),
          );
        }
      }
    }

    // 🎥 VIDEOS
    final videoDir = Directory(DirectoryView.videoDir);
    debugPrint("📂 Checking video dir: ${videoDir.path}");

    if (await videoDir.exists()) {
      await for (final entity in videoDir.list(followLinks: false)) {
        if (entity is File && _isVideo(entity.path)) {
          final stat = await entity.stat();

          debugPrint("🎞️ Found video: ${entity.path}");

          temp.add(
            _MediaWithTime(
              item: MediaItem(file: entity, type: MediaType.video),
              time: stat.modified,
            ),
          );
        }
      }
    }

    temp.sort((a, b) => b.time.compareTo(a.time));
    _media.addAll(temp.map((e) => e.item));

    debugPrint("✅ Gallery load complete, items=${_media.length}");
  } catch (e) {
    debugPrint('❌ Gallery load error: $e');
  }

  _isLoading = false;
  notifyListeners();
}


  // ==========================================================
  // 🗑️ DELETE
  // ==========================================================

  Future<bool> deleteMedia(MediaItem item) async {
    if (_isDeleting) return false;

    _isDeleting = true;
    notifyListeners();

    try {
      if (await item.file.exists()) {
        await item.file.delete();
      }
      _media.remove(item);
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      _isDeleting = false;
      notifyListeners();
      return false;
    }

    _isDeleting = false;
    notifyListeners();
    return true;
  }

  Future<int?> deleteAndResolveIndex(int currentIndex) async {
    if (currentIndex < 0 || currentIndex >= _media.length) {
      return currentIndex;
    }

    final item = _media[currentIndex];
    final deleted = await deleteMedia(item);

    if (!deleted) return currentIndex;
    if (_media.isEmpty) return null;

    if (currentIndex >= _media.length) {
      return _media.length - 1;
    }
    return currentIndex;
  }

  // ==========================================================
  // ▶️ VIDEO STATE
  // ==========================================================

  void toggleVideoPlayback() {
    _isVideoPlaying = !_isVideoPlaying;
    notifyListeners();
  }

  void setVideoPlaying(bool value) {
    _isVideoPlaying = value;
    notifyListeners();
  }

  void onVideoCompleted() {
    _isVideoPlaying = false;
    notifyListeners();
  }

  // ==========================================================
  // 🔍 HELPERS
  // ==========================================================

  bool _isImage(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png');
  }

  bool _isVideo(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.mp4') || p.endsWith('.mov') || p.endsWith('.mkv');
  }
}

// ==========================================================
// 🔥 INTERNAL SORT MODEL (FAST)
// ==========================================================

class _MediaWithTime {
  final MediaItem item;
  final DateTime time;

  _MediaWithTime({required this.item, required this.time});
}
