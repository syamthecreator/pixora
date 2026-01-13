import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';

class CameraFlashOverlay extends StatefulWidget {
  const CameraFlashOverlay({super.key});

  static final GlobalKey<CameraFlashOverlayState> flashKey =
      GlobalKey<CameraFlashOverlayState>();

  static void blink() {
    flashKey.currentState?.triggerBlink();
  }

  @override
  State<CameraFlashOverlay> createState() => CameraFlashOverlayState();
}

class CameraFlashOverlayState extends State<CameraFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  void triggerBlink() async {
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return Opacity(
            opacity: _controller.value,
            child: Container(color: AppColors.kSecondaryColour),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
