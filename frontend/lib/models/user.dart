import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String token;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AppUser.fromAuthJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['userId'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'userId': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
    };
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, 1).toUpperCase();
  }

  String get displayName {
    final parts = name.trim().split(' ');
    return parts[0];
  }
}
