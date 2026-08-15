class ApiConfig {
  static String get baseUrl {
    // Railway backend + /api prefix — matches @RequestMapping("/api/recipes") in RecipeController
    return 'https://recipebook-production-108c.up.railway.app/api';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
