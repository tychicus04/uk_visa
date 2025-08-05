import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/enums/AppLanguage.dart';
import '../core/enums/AppTheme.dart';
import '../data/models/UserStats.dart';
import '../utils/secure_storage.dart';
import '../utils/logger.dart';

import 'AppSettings.dart';
import 'AuthState.dart';
import 'ChapterState.dart';
import 'NotificationSettings.dart';
import 'TestState.dart';
import 'UserState.dart';
import 'auth_notifier.dart';
import 'test_notifier.dart';
import 'user_notifier.dart';
import 'chapter_notifier.dart';

// =============================================================================
// THEME PROVIDER
// =============================================================================

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final themeString = await SecureStorage.getTheme();
      final theme = _themeFromString(themeString);
      state = theme;
      Logger.info('Theme loaded: $themeString');
    } catch (e) {
      Logger.error('Failed to load theme', e);
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    try {
      state = theme;
      await SecureStorage.saveTheme(_themeToString(theme));
      Logger.info('Theme changed to: ${_themeToString(theme)}');
    } catch (e) {
      Logger.error('Failed to save theme', e);
    }
  }

  AppTheme _themeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'system':
      default:
        return AppTheme.system;
    }
  }

  String _themeToString(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'light';
      case AppTheme.dark:
        return 'dark';
      case AppTheme.system:
        return 'system';
    }
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
      (ref) => ThemeNotifier(),
);

// =============================================================================
// LANGUAGE PROVIDER
// =============================================================================

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final languageCode = await SecureStorage.getLanguage();
      final language = AppLanguage.fromCode(languageCode);
      state = language;
      Logger.info('Language loaded: $languageCode');
    } catch (e) {
      Logger.error('Failed to load language', e);
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    try {
      state = language;
      await SecureStorage.saveLanguage(language.code);
      Logger.info('Language changed to: ${language.code}');
    } catch (e) {
      Logger.error('Failed to save language', e);
    }
  }
}

final languageNotifierProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
      (ref) => LanguageNotifier(),
);

// =============================================================================
// NOTIFICATION SETTINGS PROVIDER
// =============================================================================

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsData = await SecureStorage.getCache('notification_settings');
      if (settingsData != null) {
        state = NotificationSettings.fromJson(settingsData);
      }
    } catch (e) {
      Logger.error('Failed to load notification settings', e);
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      state = settings;
      await SecureStorage.saveCache('notification_settings', settings.toJson());
      Logger.info('Notification settings updated');
    } catch (e) {
      Logger.error('Failed to save notification settings', e);
    }
  }

  Future<void> togglePushNotifications() async {
    await updateSettings(state.copyWith(pushNotifications: !state.pushNotifications));
  }

  Future<void> toggleEmailNotifications() async {
    await updateSettings(state.copyWith(emailNotifications: !state.emailNotifications));
  }

  Future<void> toggleStudyReminders() async {
    await updateSettings(state.copyWith(studyReminders: !state.studyReminders));
  }

  Future<void> toggleTestReminders() async {
    await updateSettings(state.copyWith(testReminders: !state.testReminders));
  }

  Future<void> toggleAchievementNotifications() async {
    await updateSettings(state.copyWith(achievementNotifications: !state.achievementNotifications));
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      (ref) => NotificationSettingsNotifier(),
);

// =============================================================================
// APP SETTINGS PROVIDER
// =============================================================================

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsData = await SecureStorage.getCache('app_settings');
      if (settingsData != null) {
        state = AppSettings.fromJson(settingsData);
      }
    } catch (e) {
      Logger.error('Failed to load app settings', e);
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      state = settings;
      await SecureStorage.saveCache('app_settings', settings.toJson());
      Logger.info('App settings updated');
    } catch (e) {
      Logger.error('Failed to save app settings', e);
    }
  }

  Future<void> toggleSoundEffects() async {
    await updateSettings(state.copyWith(soundEffects: !state.soundEffects));
  }

  Future<void> toggleVibration() async {
    await updateSettings(state.copyWith(vibration: !state.vibration));
  }

  Future<void> toggleBiometricLogin() async {
    await updateSettings(state.copyWith(biometricLogin: !state.biometricLogin));
  }

  Future<void> toggleAutoLogin() async {
    await updateSettings(state.copyWith(autoLogin: !state.autoLogin));
  }

  Future<void> toggleDataSync() async {
    await updateSettings(state.copyWith(dataSync: !state.dataSync));
  }

  Future<void> toggleOfflineMode() async {
    await updateSettings(state.copyWith(offlineMode: !state.offlineMode));
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(),
);

// =============================================================================
// CONNECTIVITY PROVIDER
// =============================================================================

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    // Initialize connectivity checking
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    // This is a simplified version. In a real app, you'd use connectivity_plus
    // package to check actual network connectivity
    try {
      // Simulate connectivity check
      await Future.delayed(const Duration(seconds: 1));
      state = true;
    } catch (e) {
      state = false;
    }
  }

  void setConnectivity(bool isConnected) {
    state = isConnected;
    Logger.info('Connectivity changed: $isConnected');
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>(
      (ref) => ConnectivityNotifier(),
);

// =============================================================================
// LOADING STATE PROVIDER
// =============================================================================

class LoadingNotifier extends StateNotifier<Map<String, bool>> {
  LoadingNotifier() : super({});

  void setLoading(String key, bool isLoading) {
    state = {
      ...state,
      key: isLoading,
    };
  }

  bool isLoading(String key) {
    return state[key] ?? false;
  }

  void clearLoading(String key) {
    final newState = Map<String, bool>.from(state);
    newState.remove(key);
    state = newState;
  }

  void clearAllLoading() {
    state = {};
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, Map<String, bool>>(
      (ref) => LoadingNotifier(),
);

// =============================================================================
// ERROR STATE PROVIDER
// =============================================================================

class ErrorNotifier extends StateNotifier<Map<String, String?>> {
  ErrorNotifier() : super({});

  void setError(String key, String? error) {
    state = {
      ...state,
      key: error,
    };
  }

  String? getError(String key) {
    return state[key];
  }

  void clearError(String key) {
    final newState = Map<String, String?>.from(state);
    newState.remove(key);
    state = newState;
  }

  void clearAllErrors() {
    state = {};
  }
}

final errorProvider = StateNotifierProvider<ErrorNotifier, Map<String, String?>>(
      (ref) => ErrorNotifier(),
);

// =============================================================================
// MAIN APP PROVIDERS EXPORT
// =============================================================================

// Export all main providers for easy access
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(),
);

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>(
      (ref) => UserNotifier(),
);

final testNotifierProvider = StateNotifierProvider<TestNotifier, TestState>(
      (ref) => TestNotifier(),
);

final chapterNotifierProvider = StateNotifierProvider<ChapterNotifier, ChapterState>(
      (ref) => ChapterNotifier(),
);

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

// Simple providers for one-time data fetching
final healthCheckProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // This would call your API health check
  return {'status': 'healthy'};
});

// Provider for checking if user has completed onboarding
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  return await SecureStorage.isOnboardingCompleted();
});

// Provider for app version info
final appVersionProvider = Provider<String>((ref) {
  return AppConstants.appVersion;
});

// Provider for checking premium status
final isPremiumProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.hasActiveSubscription ?? false;
});

// Provider for remaining free tests
final freeTestsRemainingProvider = Provider<int>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.remainingFreeTests ?? 0;
});

// Provider for user statistics
final userStatsProvider = Provider<UserStats?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.stats;
});