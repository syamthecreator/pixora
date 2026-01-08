import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/features/camera/models/camera_mode.dart';
import 'package:pixora/features/camera/service/flash_service.dart'
    show FlashService;
import '../../../core/constants/app_filters.dart';
import '../models/filter_model.dart';

/// Flash modes supported by the camera
enum FlashModeX { off, on, auto }

/// Controls camera modes, filters, flash, and recording state
class CameraControllerX extends ChangeNotifier {
  // -------------------- Filter Controller --------------------
  late final PageController filterPageController;

  // -------------------- Camera State --------------------
  int selectedMode = 0;
  int selectedFilter = 2;
  bool isRecording = false;

  // -------------------- ⏱ RECORDING TIMER --------------------
  Timer? _recordTimer;
  Duration recordingDuration = Duration.zero;

  // -------------------- Filters --------------------
  final List<FilterModel> filters = [
    FilterModel(name: "Moody", image: AppFilters.moody),
    FilterModel(name: "Vintage", image: AppFilters.vintage),
    FilterModel(name: "Natural", image: AppFilters.natural),
    FilterModel(name: "Cinematic", image: AppFilters.cinematic),
    FilterModel(name: "Vibrant", image: AppFilters.vibrant),
  ];

  CameraControllerX() {
    filterPageController = PageController(
      viewportFraction: 0.30,
      initialPage: selectedFilter,
    );
  }

  // -------------------- Filters --------------------
  void changeFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }

  // -------------------- Flash --------------------
  FlashModeX flashMode = FlashModeX.off;

  Future<void> toggleFlashMode() async {
    flashMode = flashMode == FlashModeX.off
        ? FlashModeX.on
        : flashMode == FlashModeX.on
        ? FlashModeX.auto
        : FlashModeX.off;

    await FlashService.setFlashMode(flashMode);

    notifyListeners();
  }

  IconData get flashIcon {
    switch (flashMode) {
      case FlashModeX.off:
        return Icons.flash_off;
      case FlashModeX.on:
        return Icons.flash_on;
      case FlashModeX.auto:
        return Icons.flash_auto;
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
    filterPageController.dispose();
    super.dispose();
  }
}
