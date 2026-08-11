import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // Direct Railway Live URL return karein sab platforms ke liye
    return 'https://recipebook-production-108c.up.railway.app/api';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
