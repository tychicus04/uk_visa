// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../core/storage/secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureStorageService.instance.getAuthToken();
    if (token != null) {
      // TODO: Validate token and fetch user data
      // For now, just set a dummy user
      final userId = await SecureStorageService.instance.getUserId();
      final userEmail = await SecureStorageService.instance.getUserEmail();

      if (userId != null && userEmail != null) {
        state = state.copyWith(
          user: User(
            id: int.parse(userId),
            email: userEmail,
            isPremium: false,
            languageCode: 'en',
            freeTestsUsed: 0,
            freeTestsLimit: 5,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Simulate successful login
      const token = 'dummy_token';
      const userId = '1';

      await SecureStorageService.instance.setAuthToken(token);
      await SecureStorageService.instance.setUserId(userId);
      await SecureStorageService.instance.setUserEmail(email);

      state = state.copyWith(
        isLoading: false,
        user: User(
          id: 1,
          email: email,
          isPremium: false,
          languageCode: 'en',
          freeTestsUsed: 0,
          freeTestsLimit: 5,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Simulate successful registration
      const token = 'dummy_token';
      const userId = '1';

      await SecureStorageService.instance.setAuthToken(token);
      await SecureStorageService.instance.setUserId(userId);
      await SecureStorageService.instance.setUserEmail(email);

      state = state.copyWith(
        isLoading: false,
        user: User(
          id: 1,
          email: email,
          fullName: fullName,
          isPremium: false,
          languageCode: 'en',
          freeTestsUsed: 0,
          freeTestsLimit: 5,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await SecureStorageService.instance.clearAll();
    state = const AuthState();
  }
}

