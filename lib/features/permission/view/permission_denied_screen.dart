import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/permission/controller/permission_controller.dart';
import 'package:provider/provider.dart';

class PermissionDeniedScreen extends StatefulWidget {
  const PermissionDeniedScreen({super.key});

  @override
  State<PermissionDeniedScreen> createState() => _PermissionDeniedScreenState();
}

class _PermissionDeniedScreenState extends State<PermissionDeniedScreen> {
  late PermissionController controller;

  @override
  void initState() {
    super.initState();
    controller = context.read<PermissionController>();
    controller.attach(context);
  }

  @override
  void dispose() {
    controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Permission request",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "\"Camera\" has been denied access to Camera, Microphone.\n"
                "You can enable this permission in Settings > Apps.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.kAccentYellow),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: Text(
                        "Settings",
                        style: TextStyle(color: AppColors.kAccentYellow),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
