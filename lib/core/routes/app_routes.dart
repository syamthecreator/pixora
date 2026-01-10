import 'package:flutter/material.dart';
import 'package:pixora/features/camera/view/camera_screen.dart';
import 'package:pixora/features/permission/view/permission_denied_screen.dart';
import 'package:pixora/features/settings/view/settings_page.dart';
import 'package:pixora/features/splash/view/splash_screen.dart';
import 'package:pixora/features/welcome/view/welcome_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String cameraScreen = '/cameraScreen';
  static const String settingsScreen = '/settingsScreen';
  static const String welcome = '/welcome';
  static const String permission = '/permission';

  // Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    cameraScreen: (context) => const CameraScreen(),
    settingsScreen: (context) => const CameraSettingsPage(),
    welcome: (context) => const WelcomeScreen(),
    permission: (context) => const PermissionDeniedScreen(),
  };
}
