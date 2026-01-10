import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/core/constants/app_native_side.dart';

class CameraPreviewView extends StatelessWidget {
  const CameraPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const AndroidView(
        viewType: NativeSide.cameraPreview,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: StandardMessageCodec(),
      );
    }

    return const SizedBox();
  }
}
