import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/features/camera/models/camera_mode.dart';
import 'package:pixora/core/platform/flash_service.dart' show FlashService;
import '../models/filter_model.dart';

/// Flash modes supported by the camera
enum FlashModeX { off, on, auto }

class CameraControllerX extends ChangeNotifier {
  late final PageController filterPageController;

  // -------------------- Camera State --------------------
  int selectedMode = 0;
  int selectedFilter = 2;
  bool isRecording = false;
  FlashModeX flashMode = FlashModeX.off;
  bool isFrontCamera = false;
  bool isCameraReady = false;

  // -------------------- ⏱ RECORDING TIMER --------------------
  Timer? _recordTimer;
  Duration recordingDuration = Duration.zero;

  CameraControllerX() {
    filterPageController = PageController(
      viewportFraction: 0.30,
      initialPage: selectedFilter,
    );
  }

  // -------------------- Filters --------------------
  Future<void> changeFilter(int index) async {
    selectedFilter = index;

    await const MethodChannel(
      'pixora/camera',
    ).invokeMethod('setFilter', {'filter': FilterModelList.filters[index].key});

    notifyListeners();
  }

  // -------------------- Flash --------------------

  void onCameraSwitched() {
    isFrontCamera = !isFrontCamera;

    // Always disable flash when switching camera
    flashMode = FlashModeX.off;
    FlashService.setFlashMode(FlashModeX.off);

    notifyListeners();
  }

  Future<void> toggleFlashMode() async {
    if (!isCameraReady) {
      debugPrint("Flash ignored: camera not ready");
      return;
    }

    if (isFrontCamera) {
      debugPrint("Flash ignored: front camera");
      return;
    }

    if (flashMode == FlashModeX.off) {
      flashMode = FlashModeX.on;
    } else if (flashMode == FlashModeX.on) {
      flashMode = FlashModeX.auto;
    } else {
      flashMode = FlashModeX.off;
    }

    try {
      await FlashService.setFlashMode(flashMode);
    } catch (e) {
      debugPrint("Flash channel error: $e");
    }

    notifyListeners();
  }

  IconData get flashIcon {
    switch (flashMode) {
      case FlashModeX.on:
        return Icons.flash_on;
      case FlashModeX.auto:
        return Icons.flash_auto;
      default:
        return Icons.flash_off;
    }
  }

  // -------------------- Mode Helpers --------------------
  bool get isPhotoMode => selectedMode == CameraModes.photo.index;
  bool get isVideoMode => selectedMode == CameraModes.video.index;
  bool get isSlowMode => selectedMode == CameraModes.slowMotion.index;
  bool get isVideoLike => isVideoMode || isSlowMode;

  /// Changes camera mode
  void changeMode(int index) {
    HapticFeedback.lightImpact();
    selectedMode = index;
    if (isRecording) {
      stopRecording(); // ⛔ stop + reset timer
    }
    notifyListeners();
  }

  // -------------------- Recording --------------------
  void startRecording() {
    if (!isVideoLike || isRecording) return;

    isRecording = true;
    recordingDuration = Duration.zero;

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingDuration += const Duration(seconds: 1);

      // ✅ LOG TIMER HERE
      debugPrint('🎥 Recording Time: $formattedDuration');

      notifyListeners();
    });

    notifyListeners();
  }

  void stopRecording() {
    if (!isVideoLike) return;

    // ✅ FINAL LOG
    debugPrint('⏹ Recording stopped at: $formattedDuration');

    isRecording = false;
    _recordTimer?.cancel();
    _recordTimer = null;
    notifyListeners();
  }

  /// ⏱ Format as 00:00:00
  String get formattedDuration {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(recordingDuration.inHours);
    final m = two(recordingDuration.inMinutes.remainder(60));
    final s = two(recordingDuration.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  // -------------------- Cleanup --------------------
  @override
  void dispose() {
    _recordTimer?.cancel();
    isCameraReady = false;
    flashMode = FlashModeX.off;
    FlashService.setFlashMode(FlashModeX.off);
    filterPageController.dispose();
    super.dispose();
  }
}
