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

  List<MediaItem> get media => _media;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;

  bool _isVideoPlaying = true;
  bool get isVideoPlaying => _isVideoPlaying;

  // 🔥 REAL MEDIA LOADER
  Future<void> loadMedia() async {
    _isLoading = true;
    notifyListeners();

    _media.clear();

    try {
      // 📸 Load Images
      final imageDir = Directory(DirectoryView.imageDir);
      if (await imageDir.exists()) {
        final imageFiles = imageDir
            .listSync()
            .whereType<File>()
            .where(
              (file) =>
                  file.path.toLowerCase().endsWith('.jpg') ||
                  file.path.toLowerCase().endsWith('.jpeg') ||
                  file.path.toLowerCase().endsWith('.png'),
            )
            .toList();

        for (final file in imageFiles) {
          _media.add(MediaItem(file: file, type: MediaType.image));
        }
      }

      // 🎥 Load Videos
      final videoDir = Directory(DirectoryView.videoDir);
      if (await videoDir.exists()) {
        final videoFiles = videoDir
            .listSync()
            .whereType<File>()
            .where(
              (file) =>
                  file.path.toLowerCase().endsWith('.mp4') ||
                  file.path.toLowerCase().endsWith('.mov') ||
                  file.path.toLowerCase().endsWith('.mkv'),
            )
            .toList();

        for (final file in videoFiles) {
          _media.add(MediaItem(file: file, type: MediaType.video));
        }
      }

      // 🔽 Sort by latest first
      _media.sort(
        (a, b) =>
            b.file.lastModifiedSync().compareTo(a.file.lastModifiedSync()),
      );
    } catch (e) {
      debugPrint('Gallery load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🗑️ DELETE FROM DISK + UI
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
      debugPrint('Delete error: $e');
      _isDeleting = false;
      notifyListeners();
      return false;
    }

    _isDeleting = false;
    notifyListeners();
    return true;
  }

  /// Deletes current item and returns the next index to navigate to.
  /// Returns `null` if gallery becomes empty.
  /// Deletes current item and returns the next index to navigate to.
  /// Returns `null` if gallery becomes empty.
  Future<int?> deleteAndResolveIndex(int currentIndex) async {
    debugPrint('🗑️ [Gallery] Delete requested at index: $currentIndex');

    if (currentIndex < 0 || currentIndex >= _media.length) {
      debugPrint('⚠️ [Gallery] Invalid index: $currentIndex');
      return currentIndex;
    }

    final item = _media[currentIndex];
    debugPrint('📄 [Gallery] Deleting file: ${item.file.path}');

    final deleted = await deleteMedia(item);

    if (!deleted) {
      debugPrint('❌ [Gallery] Delete failed');
      return currentIndex;
    }

    debugPrint('✅ [Gallery] Delete successful');
    debugPrint('📊 [Gallery] Remaining items count: ${_media.length}');

    if (_media.isEmpty) {
      debugPrint('🚪 [Gallery] Gallery empty, should close viewer');
      return null;
    }

    // Decide next index
    if (currentIndex >= _media.length) {
      final newIndex = _media.length - 1;
      debugPrint(
        '⬅️ [Gallery] Deleted last item, moving to previous index: $newIndex',
      );
      return newIndex;
    }

    debugPrint('➡️ [Gallery] Showing next item at same index: $currentIndex');
    return currentIndex;
  }

  // ▶️ Toggle play / pause
  void toggleVideoPlayback() {
    _isVideoPlaying = !_isVideoPlaying;
    notifyListeners();
  }

  // Reset when page changes
  void setVideoPlaying(bool value) {
    _isVideoPlaying = value;
    notifyListeners();
  }

  void onVideoCompleted() {
    _isVideoPlaying = false;
    notifyListeners();
  }
}
