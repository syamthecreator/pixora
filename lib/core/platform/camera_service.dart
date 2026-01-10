import 'package:flutter/services.dart';

class CameraService {
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
