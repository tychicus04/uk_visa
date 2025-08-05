import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/User.dart';
import '../data/models/UserStats.dart';
import '../data/requests/ChangePasswordRequest.dart';
import '../data/requests/LoginRequest.dart';
import '../data/requests/RegisterRequest.dart';
import '../data/requests/UpdateProfileRequest.dart';
import '../exceptions/ApiExceptions.dart';
import '../services/api_service.dart';
import '../utils/secure_storage.dart';
import '../utils/logger.dart';
import 'AuthState.dart';

// =============================================================================
// AUTH NOTIFIER
// =============================================================================

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    // Don't automatically check auth status here as it's called from router
    Logger.info('AuthNotifier initialized');
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  Future<void> checkAuthStatus() async {
    if (state.isInitialized) return;

    Logger.info('Checking authentication status...');

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Check if we have a stored token
      final token = await SecureStorage.getToken();

      if (token == null) {
        Logger.info('No token found - user not authenticated');
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          isInitialized: true,
        );
        return;
      }

      // Set token in API service
      ApiService.setToken(token);

      // Try to get user profile to verify token is still valid
      final user = await ApiService.getProfile();

      Logger.info('User authenticated: ${user.email}');
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        isInitialized: true,
      );

    } catch (e) {
      Logger.error('Auth check failed', e);

      // If token is invalid, clear it
      await _clearAuthData();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        isInitialized: true,
        error: _getErrorMessage(e),
      );
    }
  }

  // ==========================================================================
  // AUTHENTICATION METHODS
  // ==========================================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    Logger.info('Attempting login for: $email');

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final request = LoginRequest(email: email, password: password);
      final response = await ApiService.login(request);

      if (response.success && response.user != null) {
        Logger.info('Login successful for: ${response.user!.email}');

        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
        );

        return true;
      } else {
        throw Exception(response.message);
      }

    } catch (e) {
      Logger.error('Login failed', e);

      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );

      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String languageCode = 'en',
  }) async {
    Logger.info('Attempting registration for: $email');

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final request = RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        languageCode: languageCode,
      );

      final response = await ApiService.register(request);

      if (response.success && response.user != null) {
        Logger.info('Registration successful for: ${response.user!.email}');

        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
        );

        return true;
      } else {
        throw Exception(response.message);
      }

    } catch (e) {
      Logger.error('Registration failed', e);

      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );

      return false;
    }
  }

  Future<void> logout() async {
    Logger.info('Logging out user: ${state.user?.email}');

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Call logout API (this will clear token on server if needed)
      await ApiService.logout();

      // Clear local auth data
      await _clearAuthData();

      state = const AuthState(isInitialized: true);

      Logger.info('User logged out successfully');

    } catch (e) {
      Logger.error('Logout error', e);

      // Even if API call fails, clear local data
      await _clearAuthData();
      state = const AuthState(isInitialized: true);
    }
  }

  // ==========================================================================
  // PROFILE MANAGEMENT
  // ==========================================================================

  Future<bool> updateProfile({
    String? fullName,
    String? languageCode,
  }) async {
    if (state.user == null) return false;

    Logger.info('Updating profile for: ${state.user!.email}');

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final request = UpdateProfileRequest(
        fullName: fullName,
        languageCode: languageCode,
      );

      final updatedUser = await ApiService.updateProfile(request);

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );

      Logger.info('Profile updated successfully');
      return true;

    } catch (e) {
      Logger.error('Profile update failed', e);

      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );

      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.user == null) return false;

    Logger.info('Changing password for: ${state.user!.email}');

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await ApiService.changePassword(request);

      state = state.copyWith(isLoading: false);

      Logger.info('Password changed successfully');
      return true;

    } catch (e) {
      Logger.error('Password change failed', e);

      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );

      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated || state.user == null) return;

    try {
      final updatedUser = await ApiService.getProfile();
      state = state.copyWith(user: updatedUser);
      Logger.info('Profile refreshed successfully');
    } catch (e) {
      Logger.error('Profile refresh failed', e);
      // Don't update error state for background refresh
    }
  }

  // ==========================================================================
  // SUBSCRIPTION MANAGEMENT
  // ==========================================================================

  void updateSubscriptionStatus({
    required bool isPremium,
    DateTime? premiumExpiresAt,
  }) {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      isPremium: isPremium,
      premiumExpiresAt: premiumExpiresAt,
    );

    state = state.copyWith(user: updatedUser);
    Logger.info('Subscription status updated: isPremium=$isPremium');
  }

  void updateFreeTestsUsed(int freeTestsUsed) {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(freeTestsUsed: freeTestsUsed);
    state = state.copyWith(user: updatedUser);
    Logger.info('Free tests used updated: $freeTestsUsed');
  }

  void updateUserStats(UserStats stats) {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(stats: stats);
    state = state.copyWith(user: updatedUser);
    Logger.info('User stats updated');
  }

  // ==========================================================================
  // ERROR MANAGEMENT
  // ==========================================================================

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  Future<void> _clearAuthData() async {
    await SecureStorage.clearToken();
    await SecureStorage.clearUser();
    ApiService.clearToken();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return error.toString();
    }
  }

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  bool get isLoggedIn => state.isAuthenticated && state.user != null;

  bool get isPremium => state.user?.hasActiveSubscription ?? false;

  bool get canTakeFreeTest => state.user?.canTakeFreeTest ?? false;

  int get remainingFreeTests => state.user?.remainingFreeTests ?? 0;

  String? get userEmail => state.user?.email;

  String? get userFullName => state.user?.fullName;

  String get userLanguage => state.user?.languageCode ?? 'en';

  UserStats? get userStats => state.user?.stats;

  // ==========================================================================
  // VALIDATION HELPERS
  // ==========================================================================

  bool canAccessTest({required bool isFree, required bool isPremium}) {
    if (!state.isAuthenticated) return false;

    // Free tests can be accessed by anyone with remaining free tests or premium users
    if (isFree) {
      return canTakeFreeTest || this.isPremium;
    }

    // Premium tests require premium subscription
    if (isPremium) {
      return this.isPremium;
    }

    return true;
  }

  String? getAccessDeniedReason({required bool isFree, required bool isPremium}) {
    if (!state.isAuthenticated) return 'Please login to access tests';

    if (isFree && !canTakeFreeTest && !this.isPremium) {
      return 'You have used all your free tests. Upgrade to premium for unlimited access.';
    }

    if (isPremium && !this.isPremium) {
      return 'This test requires a premium subscription.';
    }

    return null;
  }

  // ==========================================================================
  // TESTING & DEBUG METHODS
  // ==========================================================================

  void debugPrintState() {
    Logger.debug('Current AuthState: $state');
  }

  // Force refresh auth state (useful for testing)
  Future<void> forceRefresh() async {
    state = state.copyWith(isInitialized: false);
    await checkAuthStatus();
  }
}