import 'dart:async';

import 'package:flutter/services.dart';

class MediaDeleteService {
  static const MethodChannel _channel = MethodChannel('pixora/media');

  static Future<bool> deleteImage(String path) async {
    final completer = Completer<bool>();

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'deleteResult') {
        completer.complete(call.arguments == true);
      }
    });

    await _channel.invokeMethod('deleteImage', {'path': path});

    return completer.future;
  }
}
