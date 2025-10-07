// lib/features/auth/providers/auth_provider.dart - UPDATED: Handle redirect after login
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/states/AuthState.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // For simplified auth, check if we have stored user data
      final userId = await SecureStorageService.instance.getUserId();
      final username = await SecureStorageService.instance.getUserEmail(); // Reuse for username

      if (userId != null && userId.isNotEmpty && username != null && username.isNotEmpty) {
        // Try to get profile with stored data
        await getProfile(userId);
      }
    } catch (e) {
      // Clear any invalid stored data
      await SecureStorageService.instance.clearAll();
      state = const AuthState();
    }
  }

  Future<void> register({
    required String username,
    String languageCode = 'en',
    BuildContext? context,
    String? redirectPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.register(
        username: username,
        languageCode: languageCode,
      );

      print('📊 Register API response: ${result.keys}');

      // ✅ Store user data (no tokens needed)
      await _storeUserData(result);

      // ✅ Create user object
      final user = _createUserFromResult(result);

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );

      print('✅ Registration completed successfully');

      // ✅ Handle redirect after successful registration
      if (context != null) {
        _handlePostAuthRedirect(context, redirectPath);
      }
    } catch (e) {
      print('❌ Registration failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> login({
    required String username,
    BuildContext? context,
    String? redirectPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    print('🔐 Starting login for: $username');
    if (redirectPath != null) {
      print('🔄 Redirect path: $redirectPath');
    }

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.login(
        username: username,
      );

      print('✅ Login API successful');
      print('📊 Login API response: ${result.keys}');

      // ✅ Store user data (no tokens needed) 
      await _storeUserData(result);

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

      // ✅ Handle redirect after successful login
      if (context != null) {
        _handlePostAuthRedirect(context, redirectPath);
      }

    } catch (e) {
      print('❌ Login failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> getProfile(String userId) async {
    try {
      print('👤 Getting user profile for ID: $userId');
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.getProfile(userId);

      final user = User.fromJson(result['profile']);

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );

      print('✅ Profile loaded for user: ${user.username}');
    } catch (e) {
      print('❌ Failed to get profile: $e');
      await SecureStorageService.instance.clearAll();
      state = const AuthState();
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? languageCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final updatedUser = await authRepository.updateProfile(
        userId: userId,
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

  Future<void> logout() async {
    print('🚪 Logging out user');
    // For simplified auth, just clear local data
    await SecureStorageService.instance.clearAll();
    state = const AuthState();
    print('✅ Logout completed');
  }

  // ✅ NEW: Handle post-authentication redirect
  void _handlePostAuthRedirect(BuildContext context, String? redirectPath) {
    if (redirectPath != null && redirectPath.isNotEmpty && redirectPath != '/') {
      print('🔄 Redirecting to: $redirectPath');
      context.go(redirectPath);
    } else {
      print('🔄 Redirecting to home');
      context.go('/');
    }
  }

  // ✅ Helper method to store user data for simplified auth (no tokens)
  Future<void> _storeUserData(Map<String, dynamic> result) async {
    try {
      print('💾 Storing user data...');
      print('📊 Result structure: ${result.keys}');

      // ✅ Safely extract user data as Map
      final userData = result['user'];
      if (userData == null) {
        throw Exception('No user data found in auth response');
      }

      // ✅ Ensure userData is a Map, not a User object
      Map<String, dynamic> userMap;
      if (userData is Map<String, dynamic>) {
        userMap = userData;
      } else if (userData is User) {
        // ✅ Convert User object to Map if needed
        userMap = userData.toJson();
      } else {
        throw Exception('Invalid user data type: ${userData.runtimeType}');
      }

      print('📊 User data keys: ${userMap.keys}');

      // ✅ Store user data (no tokens for simplified auth)
      await SecureStorageService.instance.setUserId(userMap['id']?.toString() ?? '0');
      await SecureStorageService.instance.setUserEmail(userMap['username']?.toString() ?? ''); // Store username as "email"

      print('✅ User data stored successfully');
    } catch (e) {
      print('❌ Failed to store user data: $e');
      print('📊 Raw result: $result');
      throw Exception('Failed to store user data: $e');
    }
  }

  // ✅ FIXED: Helper method to safely create User object
  User _createUserFromResult(Map<String, dynamic> result) {
    try {
      print('👤 Creating user from result...');
      print('📊 Result keys: ${result.keys}');

      final userData = result['user'];
      if (userData == null) {
        throw Exception('User data is null in result');
      }

      // ✅ Handle different userData types
      User user;
      if (userData is Map<String, dynamic>) {
        print('📊 Creating user from Map data: ${userData.keys}');
        user = User.fromJson(userData);
      } else if (userData is User) {
        print('📊 User data is already a User object');
        user = userData;
      } else {
        throw Exception('Invalid user data type: ${userData.runtimeType}');
      }

      print('✅ User object created successfully - ID: ${user.id}, Username: ${user.username}');
      return user;
    } catch (e) {
      print('❌ Failed to create user object: $e');
      print('📊 Raw result data: $result');
      throw Exception('Failed to parse user data: $e');
    }
  }
}