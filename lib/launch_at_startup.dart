
import 'dart:async';

import 'package:flutter/services.dart';

class LaunchAtStartup {
  static const MethodChannel _channel = MethodChannel('launch_at_startup');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
