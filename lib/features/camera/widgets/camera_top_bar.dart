import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/camera_controller.dart';
import '../models/camera_mode.dart';
import 'camera_mode_button.dart';
import 'camera_overlays.dart';

class CameraTopBar extends StatelessWidget {
  final VoidCallback onTapSettingsIcon;
  const CameraTopBar({super.key, required this.onTapSettingsIcon});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraControllerX>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// LEFT: MODE SELECTOR
            _buildModeSelector(context),

            const Spacer(),

            /// RIGHT: FLASH + SETTINGS
            Row(
              children: [
                if (!controller.isFrontCamera)
                  GestureDetector(
                    onTap: controller.toggleFlashMode,
                    child: CameraOverlayWidget.glassIcon(
                      icon: controller.flashIcon,
                    ),
                  ),

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: onTapSettingsIcon,
                  child: CameraOverlayWidget.glassIcon(icon: Icons.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    final controller = context.watch<CameraControllerX>();

    return CameraOverlayWidget.glassContainer(
      child: Row(
        children: CameraModes.all.map((mode) {
          return CameraModeButton(
            mode: mode,
            isActive: controller.selectedMode == mode.index,
            onTap: () => controller.changeMode(mode.index),
          );
        }).toList(),
      ),
    );
  }
}
