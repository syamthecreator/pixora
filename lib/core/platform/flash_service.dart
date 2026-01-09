import 'package:flutter/services.dart';
import '../../features/camera/controller/camera_controller.dart'; // adjust path if needed

class FlashService {
  static const MethodChannel _channel = MethodChannel('pixora/flash');

  static Future<void> setFlashMode(FlashModeX mode) async {
    await _channel.invokeMethod('setFlashMode', {
      'mode': mode.name, // on | auto | off
    });
  }
}
