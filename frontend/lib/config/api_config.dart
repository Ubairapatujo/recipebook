import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (Platform.isAndroid) {
      // Android Emulator ke liye local host IP
      return 'http://10.0.2.2:8080/api';
    }
    // iOS Simulator ya physical device (Agar mobile real phone hai to apni PC IP daalein)
    return 'http://localhost:8080/api';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
