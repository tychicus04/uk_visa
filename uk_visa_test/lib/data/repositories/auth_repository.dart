import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService);
});

class AuthRepository {

  AuthRepository(this._authService);
  final AuthService _authService;

  Future<Map<String, dynamic>> register({
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
      return {
        'user': User.fromJson(userData),
        'token': response.data!['token'] as String,
        'tokenType': response.data!['token_type'] as String,
      };
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
      final userData = response.data!['user'] as Map<String, dynamic>;
      return {
        'user': User.fromJson(userData),
        'token': response.data!['token'] as String,
        'tokenType': response.data!['token_type'] as String,
        'expiresIn': response.data!['expires_in'] as String?,
      };
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _authService.getProfile();

    if (response.success && response.data != null) {
      final userData = response.data!['profile'] as Map<String, dynamic>;
      final userStats = response.data!['stats'] as Map<String, dynamic>?;
      return {
        'profile': User.fromJson(userData),
        'stats': userStats?.map((key, value) => MapEntry(key, value.toString()))
      };
    } else {
      throw Exception(response.message ?? 'Failed to get profile');
    }
  }

  Future<User> updateProfile({
    required String fullName,
    String? languageCode,
  }) async {
    final response = await _authService.updateProfile(
      fullName: fullName,
      languageCode: languageCode,
    );

    if (response.success && response.data != null) {
      final userData = response.data!;
      return User.fromJson(userData);
    } else {
      throw Exception(response.message ?? 'Failed to update profile');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (response.data != null) {
      // Handle any additional data if needed
      print('Password change response: ${response.success}');
    }
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to change password');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
