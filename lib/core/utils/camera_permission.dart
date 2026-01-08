import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureCameraPermission(BuildContext context) async {
  final status = await Permission.camera.status;

  if (status.isGranted) return true;

  final result = await Permission.camera.request();

  if (result.isGranted) return true;

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera permission is required to continue'),
      ),
    );
  }
  return false;
}
