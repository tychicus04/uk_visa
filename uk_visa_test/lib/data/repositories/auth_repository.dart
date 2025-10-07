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
    required String username,
    String languageCode = 'en',
  }) async {
    final response = await _authService.register(
      username: username,
      languageCode: languageCode,
    );

    if (response.success && response.data != null) {
      final userData = response.data!['user'] as Map<String, dynamic>;
      return {
        'user': User.fromJson(userData),
      };
    } else {
      throw Exception(response.message ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
  }) async {
    final response = await _authService.login(
      username: username,
    );

    if (response.success && response.data != null) {
      final userData = response.data!['user'] as Map<String, dynamic>;
      return {
        'user': userData, // Pass raw data to be parsed by User.fromJson
      };
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await _authService.getProfile(userId: userId);

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
    required String userId,
    String? languageCode,
  }) async {
    final response = await _authService.updateProfile(
      userId: userId,
      languageCode: languageCode,
    );

    if (response.success && response.data != null) {
      final userData = response.data!;
      return User.fromJson(userData);
    } else {
      throw Exception(response.message ?? 'Failed to update profile');
    }
  }

  Future<void> logout() async {
    // For simplified auth, logout is just client-side cleanup
    return;
  }
}
