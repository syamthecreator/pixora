import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixora/core/utils/permission_handler.dart';
import 'package:pixora/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'welcome_controller.dart';

class WelcomeAnimationController extends ChangeNotifier {
  // ───────────────── Animations ─────────────────

  late final AnimationController mainController;
  late final Animation<double> fade;
  late final Animation<double> scale;

  late final AnimationController arrowController;
  late final Animation<double> arrowOpacity;

  // ───────────────── Swipe State ─────────────────

  static const double maxDragDistance = 120.0;
  static const double completionThreshold = 0.75;

  double dragOffset = 0.0;
  bool _navigating = false;

  WelcomeAnimationController(TickerProvider vsync) {
    _initMainAnimations(vsync);
    _initArrowAnimations(vsync);
  }

  // ───────────────── Init ─────────────────

  void _initMainAnimations(TickerProvider vsync) {
    mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    fade = CurvedAnimation(parent: mainController, curve: Curves.easeOut);

    scale = Tween(begin: 1.06, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeOut),
    );
  }

  void _initArrowAnimations(TickerProvider vsync) {
    arrowController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    arrowOpacity = Tween(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: arrowController, curve: Curves.easeInOut),
    );
  }

  // ───────────────── Swipe Logic ─────────────────

  void onDragUpdate(DragUpdateDetails details) {
    dragOffset = (dragOffset - details.delta.dx)
        .clamp(0.0, maxDragDistance);

    notifyListeners(); // 🔥 UI updates here
  }

  Future<void> onDragEnd(
    DragEndDetails details,
    BuildContext context,
  ) async {
    if (_navigating) return;

    final velocity = details.primaryVelocity ?? 0;

    final isComplete =
        dragOffset > maxDragDistance * completionThreshold ||
        velocity < -600;

    dragOffset = 0;
    notifyListeners();

    if (isComplete) {
      _navigating = true;
      await continueFlowFromWelcome(context);
    }
  }

  // ───────────────── Navigation ─────────────────

  Future<void> continueFlowFromWelcome(BuildContext context) async {
    HapticFeedback.lightImpact();

    await context.read<WelcomeController>().markCompleted();
    if (!context.mounted) return;

    final hasPermission = await checkCameraMicPermission();
    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      hasPermission
          ? AppRoutes.cameraScreen
          : AppRoutes.permission,
    );
  }

  // ───────────────── Dispose ─────────────────

  @override
  void dispose() {
    mainController.dispose();
    arrowController.dispose();
    super.dispose();
  }
}
