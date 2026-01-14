import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/core/platform/camera_service.dart';
import 'package:pixora/core/platform/flash_service.dart';
import 'package:pixora/core/routes/app_routes.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/camera/models/camera_mode.dart';
import 'package:pixora/features/camera/widgets/camera_blink_overlays.dart';
import 'package:pixora/features/camera/widgets/quick_settings_sheet.dart';
import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/settings/controller/settings_controller.dart';
import 'package:provider/provider.dart';

import '../models/filter_model.dart';

/// Flash modes supported by the camera
enum FlashModeX { off, on, auto }

class CameraControllerX extends ChangeNotifier {
  // -------------------- Controllers --------------------
  late final PageController filterPageController;

  // -------------------- Camera State --------------------
  int selectedMode = 0;
  int selectedFilter = 2;
  bool isRecording = false;
  bool isFrontCamera = false;
  bool isCameraReady = false;
  bool gridLines = true;

  FlashModeX flashMode = FlashModeX.off;

  int _previewKey = 0;
  int get previewKey => _previewKey;

  static Future<String?>? _videoSaveFuture;

  static const List<String> _availableTimers = ["Off", "3s", "5s", "10s"];
  List<String> get availableTimers => _availableTimers;
  String selectedTimer = "Off";

  static const List<String> _availableRatios = ["4:3", "16:9", "Full"];
  List<String> get availableRatios => _availableRatios;
  String selectedRatio = "4:3";
  String get _selectedRatio => selectedRatio;

  bool _showCountdown = false;
  int _countdown = 0;

  bool get showCountdown => _showCountdown;
  int get countdown => _countdown;

  static const Duration _quickSettingsAnimationDuration = Duration(
    milliseconds: 300,
  );
  static const double _quickSettingsBarrierOpacity = 0.6;

  // -------------------- ⏱ RECORDING TIMER --------------------
  Timer? _recordTimer;
  Duration recordingDuration = Duration.zero;

  // -------------------- Constructor --------------------
  CameraControllerX() {
    filterPageController = PageController(
      viewportFraction: 0.30,
      initialPage: selectedFilter,
    );
  }

  // -------------------- Helpers --------------------
  int getTimerIndex() => _availableTimers.indexOf(selectedTimer);

  /// Returns selected ratio index
  int getRatioIndex() => _availableRatios.indexOf(selectedRatio);

  bool get isPhotoMode => selectedMode == CameraModes.photo.index;
  bool get isVideoMode => selectedMode == CameraModes.video.index;
  bool get isVideoLike => isVideoMode;

  /// ⏱ Format as 00:00:00
  String get formattedDuration {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(recordingDuration.inHours);
    final m = two(recordingDuration.inMinutes.remainder(60));
    final s = two(recordingDuration.inSeconds.remainder(60));
    return '$h:$m:$s';
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

  // -------------------- Mode --------------------
  void changeMode(int index) {
    HapticFeedback.lightImpact();
    selectedMode = index;

    if (isRecording) {
      stopRecording();
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
      debugPrint('🎥 Recording Time: $formattedDuration');
      notifyListeners();
    });

    notifyListeners();
  }

  void stopRecording() {
    if (!isVideoLike) return;

    debugPrint('⏹ Recording stopped at: $formattedDuration');

    isRecording = false;
    _recordTimer?.cancel();
    _recordTimer = null;

    notifyListeners();
  }

  /// Toggles grid overlay
  void toggleGridLines() {
    gridLines = !gridLines;
    notifyListeners();
  }

  // -------------------- App Lifecycle --------------------
  void restartCamera() {
    debugPrint('🟢 Restarting camera');

    _previewKey++;
    isCameraReady = false;

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 200), () {
      isCameraReady = true;
      notifyListeners();
    });
  }

  void disposeCamera() {
    debugPrint('🔴 Disposing camera');

    isCameraReady = false;

    if (isRecording) {
      stopRecording();
    }

    flashMode = FlashModeX.off;
    FlashService.setFlashMode(FlashModeX.off);

    notifyListeners();
  }

  // -------------------- Capture --------------------
  Future<void> handleTap(BuildContext context) async {
    log("📸 TAP: Capture button pressed");

    if (isPhotoMode) {
      final timerSeconds = getSelectedTimerSeconds();

      if (timerSeconds > 0) {
        await startPhotoCountdown(context, timerSeconds);
        return;
      }

      await capturePhoto(context);
      return;
    }

    if (!isRecording) {
      log("🎥 START recording");
      startRecording();
      _videoSaveFuture = CameraService.startRecording();
      return;
    }

    log("🎥 STOP recording");
    await handleStop();
  }

  Future<void> handleStop() async {
    if (!isRecording) return;

    stopRecording();
    await CameraService.stopRecording();

    final uri = await _videoSaveFuture;
    if (uri != null) {
      log("Video saved: $uri");
    }

    _videoSaveFuture = null;
  }

  // -------------------- Photo Countdown --------------------
  Future<void> startPhotoCountdown(BuildContext context, int seconds) async {
    startCountdown(seconds);

    for (int i = seconds; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      tickCountdown();
    }

    endCountdown();

    if (!context.mounted) return;
    await capturePhoto(context);
  }

  Future<void> capturePhoto(BuildContext context) async {
    CameraFlashOverlay.blink();

    final uri = await CameraService.takePhoto(flashMode.name);
    log("📸 takePhoto() returned: $uri");

    if (uri != null && context.mounted) {
      refreshGallery(context, newUri: uri);
    }
  }

  void refreshGallery(BuildContext context, {required String newUri}) {
    try {
      final gallery = context.read<GalleryController>();
      log("🔄 Gallery refresh requested with new URI");
      gallery.loadMedia();
    } catch (e) {
      log("⚠️ Gallery not in tree: $e");
    }
  }

  // -------------------- Countdown State --------------------
  void startCountdown(int seconds) {
    _countdown = seconds;
    _showCountdown = true;
    notifyListeners();
  }

  void tickCountdown() {
    _countdown--;
    notifyListeners();
  }

  void endCountdown() {
    _showCountdown = false;
    _countdown = 0;
    notifyListeners();
  }

  // -------------------- Timer --------------------
  void selectTimer(String timer) {
    if (selectedTimer != timer) {
      selectedTimer = timer;
      notifyListeners();
    }
  }

  int getSelectedTimerSeconds() {
    switch (selectedTimer) {
      case "3s":
        return 3;
      case "5s":
        return 5;
      case "10s":
        return 10;
      default:
        return 0;
    }
  }

  /// Shows quick settings overlay
  void showQuickSettings(BuildContext context) {
    final settingsController = context.read<SettingsController>();

    showGeneralDialog(
      context: context,
      barrierLabel: "QuickSettings",
      barrierDismissible: true,
      barrierColor: AppColors.kSecondaryColour.withAlpha(
        (255 * _quickSettingsBarrierOpacity).toInt(),
      ),
      transitionDuration: _quickSettingsAnimationDuration,

      pageBuilder: (_, _, _) {
        return SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: QuickSettingsSheet(
                onClose: () => hideQuickSettings(context),
                onMoreSettings: () => moreSettings(context),
                settingsController: settingsController,
                cameraControllerX: this,
              ),
            ),
          ),
        );
      },

      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  /// Closes quick settings overlay
  void hideQuickSettings(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Opens full settings screen
  void moreSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AppRoutes.settingsScreen);
  }

  /// Used to force AndroidView rebuild

  void updateRatio(String ratio) {
    if (_selectedRatio == ratio) return;
    selectedRatio = ratio;
    _previewKey++;

    notifyListeners();
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
