// lib/data/repositories/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService);
});

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String languageCode = 'en',
  }) async {
    final response = await _authService.register(
      email: email,
      password: password,
      fullName: fullName,
      languageCode: languageCode,
    );

    if (response.success && response.data != null) {
      final userData = response.data!['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } else {
      throw Exception(response.message ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(
      email: email,
      password: password,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  Future<User> getProfile() async {
    final response = await _authService.getProfile();

    if (response.success && response.data != null) {
      final userData = response.data!['profile'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } else {
      throw Exception(response.message ?? 'Failed to get profile');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
