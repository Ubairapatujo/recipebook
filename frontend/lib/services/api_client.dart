import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiClient {
  static Map<String, String> _headers([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return await http.get(uri, headers: _headers(token));
  }

  static Future<http.Response> post(String path,
      {Map<String, dynamic>? body, String? token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return await http.post(uri,
        headers: _headers(token), body: body != null ? jsonEncode(body) : null);
  }

  static Future<http.Response> put(String path,
      {Map<String, dynamic>? body, String? token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return await http.put(uri,
        headers: _headers(token), body: body != null ? jsonEncode(body) : null);
  }

  static Future<http.Response> delete(String path, {String? token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return await http.delete(uri, headers: _headers(token));
  }

  static String extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded['message'] != null) return decoded['message'];
      if (decoded['errors'] != null) {
        return (decoded['errors'] as Map).values.join(', ');
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }
}
