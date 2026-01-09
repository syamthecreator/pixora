import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/core/utils/permission_handler.dart';
import 'package:pixora/features/camera/controller/camera_controller.dart';
import 'package:pixora/features/camera/widgets/camera_bottom_bar.dart';
import 'package:pixora/features/camera/widgets/camera_filter_bar.dart';
import 'package:pixora/features/camera/widgets/camera_preview.dart';
import 'package:pixora/features/camera/widgets/camera_top_bar.dart';
import 'package:pixora/features/settings/controller/settings_controller.dart';
import 'package:pixora/routes/app_routes.dart';
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

    // ✅ MARK CAMERA READY AFTER FIRST FRAME
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraControllerX>().isCameraReady = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final ok = await checkCameraMicAndMediaPermission();
    if (!ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.permission);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final ok = await checkCameraMicAndMediaPermission();

      if (!ok && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.permission);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔥 CAMERA BACKGROUND
          const Positioned.fill(child: CameraPreviewView()),

          // 🔝 TOP BAR
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraTopBar(
                onTapSettingsIcon: () => settings.showQuickSettings(context),
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
              padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: const CameraBottomBar(),
            ),
          ),
        ],
      ),
    );
  }
}
