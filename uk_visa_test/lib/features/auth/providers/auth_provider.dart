import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/states/AuthState.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await SecureStorageService.instance.getAuthToken();

      if (token != null && token.isNotEmpty) {
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
      await _storeAuthData(result);

      final user = _createUserFromResult(result);

      state = state.copyWith(
        isLoading: false,
        user: user,
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
    print('🔐 Starting login for: $email');

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.login(
        email: email,
        password: password,
      );

      print('✅ Login API successful');

      // ✅ Store tokens and user info safely
      await _storeAuthData(result);

      // ✅ Create user object with error handling
      final user = _createUserFromResult(result);

      // ✅ Update state before navigation
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );

      print('✅ Login state updated - User: ${user.email}, Auth: ${state.isAuthenticated}');

      // ✅ Add small delay to ensure state is propagated
      await Future.delayed(const Duration(milliseconds: 100));

    } catch (e) {
      print('❌ Login failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> getProfile() async {
    try {
      print('👤 Getting user profile');
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.getProfile();

      final user = User.fromJson(result['profile']);

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );

      print('✅ Profile loaded - User: ${user.email}');
    } catch (e) {
      print('❌ Get profile failed: $e');
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
    print('🚪 Logging out user');
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout();
    } catch (e) {
      // Ignore logout errors
      print('⚠️ Logout API error (ignored): $e');
    } finally {
      await SecureStorageService.instance.clearAll();
      state = const AuthState();
      print('✅ Logout completed');
    }
  }

  // ✅ Helper method to safely store auth data
  Future<void> _storeAuthData(Map<String, dynamic> result) async {
    try {
      final token = result['token']?.toString();
      final userData = result['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        await SecureStorageService.instance.setAuthToken(token);
        await SecureStorageService.instance.setUserId(userData['id']?.toString() ?? '0');
        await SecureStorageService.instance.setUserEmail(userData['email']?.toString() ?? '');
        print('✅ Auth data stored successfully');
      } else {
        throw Exception('Invalid auth response: missing token or user data');
      }
    } catch (e) {
      print('❌ Failed to store auth data: $e');
      throw Exception('Failed to store authentication data');
    }
  }

  // ✅ Helper method to safely create User object
  User _createUserFromResult(Map<String, dynamic> result) {
    try {
      final userData = result['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception('User data is null');
      }

      print('📊 Creating user from data: ${userData.keys}');
      final user = User.fromJson(userData);
      print('✅ User object created successfully');
      return user;
    } catch (e) {
      print('❌ Failed to create user object: $e');
      print('📊 Raw user data: $result');
      throw Exception('Failed to parse user data: $e');
    }
  }
}