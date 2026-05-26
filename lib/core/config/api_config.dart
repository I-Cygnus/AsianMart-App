import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Default host for a physical Android device on the same Wi-Fi network.
  // Override with --dart-define=API_BASE_URL=http://<your-ip>:8080 when needed.
  static const String _androidDeviceBaseUrl = 'http://192.168.0.10:8080';

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (Platform.isAndroid) {
      return _androidDeviceBaseUrl;
    }
    return 'http://localhost:8080';
  }
}
