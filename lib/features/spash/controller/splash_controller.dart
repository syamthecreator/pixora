import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixora/features/welcome/controller/welcome_controller.dart';
import 'package:pixora/routes/app_routes.dart';
import 'package:provider/provider.dart';

/// Handles splash screen animations and navigation
class SplashController extends ChangeNotifier {
  AnimationController? pulseController;
  AnimationController? rotateController;

  late Animation<double> scale;
  late Animation<double> fade;
  late Animation<double> rotation;

  /// Initializes splash animations
  void init(TickerProvider vsync) {
    pulseController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    rotateController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 6),
    )..repeat();

    scale = Tween(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: pulseController!, curve: Curves.easeInOut),
    );

    fade = Tween(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: pulseController!, curve: Curves.easeIn));

    rotation = Tween(begin: 0.0, end: 2 * pi).animate(rotateController!);
  }

  /// Navigates to camera screen after delay
  Future<void> navigate(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;

    final welcomeController = context.read<WelcomeController>();
    await welcomeController.load();

    if (welcomeController.isFirstLaunch) {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    } else {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.cameraScreen);
    }
  }

  /// Disposes animation controllers
  void disposeAnimations() {
    pulseController?.dispose();
    rotateController?.dispose();
  }
}
