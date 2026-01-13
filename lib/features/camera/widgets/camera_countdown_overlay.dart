import 'package:flutter/material.dart';
import 'package:pixora/features/camera/controller/camera_controller.dart';
import 'package:provider/provider.dart';

class CameraCountdownOverlay extends StatelessWidget {
  const CameraCountdownOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraControllerX>(
      builder: (_, controller, _) {
        if (!controller.showCountdown) return const SizedBox();

        return Container(
          color: Colors.black45,
          alignment: Alignment.center,
          child: Text(
            controller.countdown.toString(),
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
