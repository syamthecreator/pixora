import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/core/utils/permission_handler.dart';
import 'package:pixora/features/camera/controller/camera_controller.dart';
import 'package:pixora/features/camera/widgets/camera_blink_overlays.dart';
import 'package:pixora/features/camera/widgets/camera_bottom_bar.dart';
import 'package:pixora/features/camera/widgets/camera_countdown_overlay.dart';
import 'package:pixora/features/camera/widgets/camera_filter_bar.dart';
import 'package:pixora/features/camera/widgets/camera_preview.dart';
import 'package:pixora/features/camera/widgets/camera_top_bar.dart';
import 'package:pixora/core/routes/app_routes.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _checkPermission();

    /// 🔥 Camera becomes ready AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CameraControllerX>().isCameraReady = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    /// 🔴 Ensure camera is disposed when screen is destroyed
    context.read<CameraControllerX>().disposeCamera();

    super.dispose();
  }

  Future<void> _checkPermission() async {
    final ok = await checkCameraMicPermission();
    if (!ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.permission);
    }
  }

  /// ✅ THIS IS THE MOST IMPORTANT FIX
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final camera = context.read<CameraControllerX>();

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // 🔴 App going background → RELEASE CAMERA
      camera.disposeCamera();
    }

    if (state == AppLifecycleState.resumed) {
      final ok = await checkCameraMicPermission();

      if (!ok && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.permission);
        return;
      }

      // 🟢 App back → RESTART CAMERA (forces AndroidView rebuild)
      camera.restartCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraControllerX = context.watch<CameraControllerX>();

    return Scaffold(
      backgroundColor: AppColors.kSecondaryColour,
      body: Stack(
        children: [
          // 🔥 CAMERA PREVIEW
          const Positioned.fill(child: CameraPreviewView()),

          // 🔝 TOP BAR
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraTopBar(
                onTapSettingsIcon: () =>
                    cameraControllerX.showQuickSettings(context),
              ),
            ),
          ),

          // 🎨 FILTER BAR
          const Positioned(
            left: 0,
            right: 0,
            bottom: 90,
            child: CameraFilterBar(),
          ),

          // ⬇️ BOTTOM BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.kSecondaryColour,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: const CameraBottomBar(),
            ),
          ),
          // ⏱️ COUNTDOWN (ABOVE UI)
          const Positioned.fill(child: CameraCountdownOverlay()),
          // 🔥🔥 CAMERA CAPTURE BLINK OVERLAY (ADD THIS)
          Positioned.fill(
            child: CameraFlashOverlay(key: CameraFlashOverlay.flashKey),
          ),
        ],
      ),
    );
  }
}
