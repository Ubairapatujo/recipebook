class ApiConfig {
  static String get baseUrl {
    // Direct Railway Live URL (without trailing /api)
    return 'https://recipebook-production-108c.up.railway.app';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
