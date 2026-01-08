import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'welcome_controller.dart';

class WelcomeAnimationController {
  late final AnimationController mainController;
  late final Animation<double> fade;
  late final Animation<double> scale;

  late final AnimationController arrowController;
  late final Animation<double> arrowOpacity;

  WelcomeAnimationController(TickerProvider vsync) {
    mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    fade = CurvedAnimation(
      parent: mainController,
      curve: Curves.easeOut,
    );

    scale = Tween(begin: 1.06, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeOut),
    );

    arrowController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    arrowOpacity = Tween(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: arrowController, curve: Curves.easeInOut),
    );
  }

  Future<void> continueFlow(BuildContext context) async {
    HapticFeedback.lightImpact();
    await context.read<WelcomeController>().markCompleted();

    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.cameraScreen,
      );
    }
  }

  void dispose() {
    mainController.dispose();
    arrowController.dispose();
  }
}
