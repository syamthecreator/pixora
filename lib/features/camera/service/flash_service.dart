import 'package:flutter/services.dart';
import '../controller/camera_controller.dart'; // adjust path if needed

class FlashService {
  static const MethodChannel _channel = MethodChannel('pixora/flash');

  static Future<void> setFlashMode(FlashModeX mode) async {
    await _channel.invokeMethod('setFlashMode', {
      'mode': mode.name, // off | on | auto
    });
  }
}

class CameraPlatform {
  static const _channel = MethodChannel('pixora/camera');

  static Future<String?> takePhoto(String flash) async {
    return await _channel.invokeMethod('takePhoto', {'flash': flash});
  }

  static Future<void> switchCamera() async {
    await _channel.invokeMethod('switchCamera');
  }

  static Future<String?> startRecording() async {
    return await _channel.invokeMethod('startRecording');
  }

  static Future<void> stopRecording() async {
    await _channel.invokeMethod('stopRecording');
  }
}
