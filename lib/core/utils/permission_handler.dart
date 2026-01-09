import 'package:permission_handler/permission_handler.dart';

/// Camera + Mic + Gallery permission
Future<bool> checkCameraMicAndMediaPermission() async {
  // ---------------- CAMERA & MIC ----------------
  final cameraStatus = await Permission.camera.status;
  final micStatus = await Permission.microphone.status;

  if (!cameraStatus.isGranted) {
    if (cameraStatus.isPermanentlyDenied) return false;
    final camReq = await Permission.camera.request();
    if (!camReq.isGranted) return false;
  }

  if (!micStatus.isGranted) {
    if (micStatus.isPermanentlyDenied) return false;
    final micReq = await Permission.microphone.request();
    if (!micReq.isGranted) return false;
  }

  return true;
}
