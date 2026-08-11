import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static const String _storageKey = 'recipebook_user';

  Future<AppUser> login(String email, String password) async {
    final response = await ApiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      final user = AppUser.fromAuthJson(jsonDecode(response.body));
      await _saveUser(user);
      return user;
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  Future<AppUser> register(String name, String email, String password) async {
    final response = await ApiClient.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      final user = AppUser.fromAuthJson(jsonDecode(response.body));
      await _saveUser(user);
      return user;
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<AppUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return null;
    return AppUser.fromAuthJson(jsonDecode(data));
  }

  Future<void> _saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toStorageJson()));
  }
}
