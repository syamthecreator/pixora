import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/core/platform/camera_service.dart';
import 'package:pixora/features/camera/widgets/camera_blink_overlays.dart';
import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/gallery/view/gallery_grid_screen.dart';
import 'package:provider/provider.dart';
import '../controller/camera_controller.dart';
import 'camera_overlays.dart';

class CameraBottomBar extends StatelessWidget {
  const CameraBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomInset),
      child: const _BottomBarContent(),
    );
  }
}

class _BottomBarContent extends StatelessWidget {
  const _BottomBarContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _GalleryButton(),
        _CaptureSection(),
        _FlipCameraButton(),
      ],
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GalleryGridScreen()),
        );
      },
      child: CameraOverlayWidget.glassIcon(icon: Icons.photo_library, size: 20),
    );
  }
}

class _FlipCameraButton extends StatelessWidget {
  const _FlipCameraButton();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraControllerX>();

    return GestureDetector(
      onTap: () {
        CameraService.switchCamera();
        controller.onCameraSwitched();
      },
      child: CameraOverlayWidget.glassIcon(
        icon: Icons.autorenew_rounded,
        size: 20,
      ),
    );
  }
}

class _CaptureSection extends StatelessWidget {
  const _CaptureSection();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraControllerX>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CaptureButton(controller: controller),
        const SizedBox(height: 8),
        _RecordingTimer(controller: controller),
      ],
    );
  }
}

class _RecordingTimer extends StatelessWidget {
  final CameraControllerX controller;

  const _RecordingTimer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Selector<CameraControllerX, bool>(
      selector: (_, c) => c.isRecording,
      builder: (_, isRecording, _) {
        if (!isRecording || !controller.isVideoLike) {
          return const SizedBox.shrink();
        }

        return Selector<CameraControllerX, String>(
          selector: (_, c) => c.formattedDuration,
          builder: (_, time, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  color: Colors.redAccent,
                  size: 10,
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.kWhiteColour,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final CameraControllerX controller;

  const _CaptureButton({required this.controller});

  static Future<String?>? _videoSaveFuture;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPressEnd: (_) => _handleStop(),
      child: const SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [_OuterRing(), _MiddleRing(), _CaptureCenter()],
        ),
      ),
    );
  }

  // ---------------- TAP ----------------
  Future<void> _handleTap(BuildContext context) async {
    log("📸 TAP: Capture button pressed");

    if (controller.isPhotoMode) {
      CameraFlashOverlay.blink();

      final uri = await CameraService.takePhoto(controller.flashMode.name);

      log("📸 takePhoto() returned: $uri");

      if (uri != null && context.mounted) {
        _refreshGallery(context, newUri: uri);
      }
      return;
    }

    // ---------- START VIDEO ----------
    if (!controller.isRecording) {
      log("🎥 START recording");
      controller.startRecording();
      _videoSaveFuture = CameraService.startRecording();
      return;
    }

    // ---------- STOP VIDEO ----------
    log("🎥 STOP recording");
    await _handleStop();
  }

  void _refreshGallery(BuildContext context, {required String newUri}) {
    try {
      final gallery = context.read<GalleryController>();

      log("🔄 Gallery refresh requested with new URI");

      gallery.loadMedia(); // full reload (safe)
    } catch (e) {
      log("⚠️ Gallery not in tree: $e");
    }
  }

  // ---------------- STOP (tap OR long-press) ----------------
  Future<void> _handleStop() async {
    if (!controller.isRecording) return;

    controller.stopRecording();
    await CameraService.stopRecording();

    // 🔑 WAIT FOR FINALIZE
    final uri = await _videoSaveFuture;

    if (uri != null) {
      log("Video saved: $uri");
    }

    _videoSaveFuture = null;
  }
}

class _OuterRing extends StatelessWidget {
  const _OuterRing();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 4),
      ),
    );
  }
}

class _MiddleRing extends StatelessWidget {
  const _MiddleRing();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraControllerX>();
    final isPhoto = controller.isPhotoMode;

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isPhoto
              ? AppColors.kPrimaryColour
              : AppColors.kSecondaryColour,
          width: 3,
        ),
      ),
    );
  }
}

class _CaptureCenter extends StatelessWidget {
  const _CaptureCenter();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraControllerX>();

    return Selector<CameraControllerX, bool>(
      selector: (_, c) => c.isRecording,
      builder: (_, isRecording, _) {
        final isRecordingMode = controller.isVideoLike && isRecording;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isRecordingMode ? 34 : 44,
          height: isRecordingMode ? 34 : 44,
          decoration: BoxDecoration(
            color: controller.isVideoLike
                ? Colors.redAccent
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isRecordingMode ? 8 : 50),
          ),
        );
      },
    );
  }
}
