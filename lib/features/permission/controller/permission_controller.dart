import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixora/routes/app_routes.dart';

class PermissionController extends ChangeNotifier with WidgetsBindingObserver {
  BuildContext? _context;

  /// Attach context when screen opens
  void attach(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Detach when screen closes
  void detach() {
    WidgetsBinding.instance.removeObserver(this);
    _context = null;
  }

  /// Check permission status
  Future<bool> hasPermission() async {
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    return camera.isGranted && mic.isGranted;
  }

  /// Called when user comes back from Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && _context != null) {
      final ok = await hasPermission();

      if (ok && _context!.mounted) {
        Navigator.pushReplacementNamed(_context!, AppRoutes.cameraScreen);
      }
    }
  }
}
