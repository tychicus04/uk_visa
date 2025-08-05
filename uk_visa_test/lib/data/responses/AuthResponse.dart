import '../models/User.dart';

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final String? tokenType;
  final int? expiresIn;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.tokenType,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: data['user'] != null ? User.fromJson(data['user']) : null,
      token: data['token'],
      tokenType: data['token_type'] ?? 'Bearer',
      expiresIn: data['expires_in'],
    );
  }
}