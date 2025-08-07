import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) => AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await SecureStorageService.instance.getAuthToken();
      if (token != null && token.isNotEmpty) {
        // Try to get user profile to validate token
        await getProfile();
      }
    } catch (e) {
      // Token might be invalid, clear it
      await SecureStorageService.instance.clearAll();
      state = const AuthState();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String languageCode = 'en',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        languageCode: languageCode,
      );

      // Store tokens and user info
      await SecureStorageService.instance.setAuthToken(result['token']);
      await SecureStorageService.instance.setUserId(result['user']['id'].toString());
      await SecureStorageService.instance.setUserEmail(result['user']['email']);

      state = state.copyWith(
        isLoading: false,
        user: User.fromJson(result['user']),
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.login(
        email: email,
        password: password,
      );

      // Store tokens and user info
      await SecureStorageService.instance.setAuthToken(result['token']);
      await SecureStorageService.instance.setUserId(result['user']['id'].toString());
      await SecureStorageService.instance.setUserEmail(result['user']['email']);

      state = state.copyWith(
        isLoading: false,
        user: User.fromJson(result['user']),
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> getProfile() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.getProfile();

      state = state.copyWith(
        isLoading: false,
        user: User.fromJson(user['profile']),
        isAuthenticated: true,
      );
    } catch (e) {
      // If getting profile fails, user might not be authenticated
      await logout();
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? languageCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final updatedUser = await authRepository.updateProfile(
        fullName: fullName,
        languageCode: languageCode,
      );

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout();
    } catch (e) {
      // Ignore logout errors
      print('Logout error: $e');
    } finally {
      await SecureStorageService.instance.clearAll();
      state = const AuthState();
    }
  }
}
