import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/core/constants/app_native_side.dart';
import 'package:pixora/features/camera/controller/camera_controller.dart';
import 'package:provider/provider.dart';

class CameraPreviewView extends StatelessWidget {
  const CameraPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = context.watch<CameraControllerX>();

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        key: ValueKey(camera.previewKey),
        viewType: NativeSide.cameraPreview,
        layoutDirection: TextDirection.ltr,
        creationParams: {'ratio': camera.selectedRatio},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return const SizedBox();
  }
}
