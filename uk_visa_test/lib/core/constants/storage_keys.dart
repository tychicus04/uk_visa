// lib/core/constants/storage_keys.dart
class StorageKeys {
  // Auth
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';

  // App Settings
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String practiceTime = 'practice_time';
  static const String isFirstLaunch = 'is_first_launch';

  // 🆕 BILINGUAL SETTINGS
  static const String bilingualEnabled = 'bilingual_enabled';
  static const String primaryLanguage = 'primary_language';
  static const String secondaryLanguage = 'secondary_language';
  static const String showBothLanguages = 'show_both_languages';
  static const String autoTranslate = 'auto_translate';

  // User Preferences
  static const String selectedChapters = 'selected_chapters';
  static const String studyGoals = 'study_goals';
  static const String examDate = 'exam_date';

  // Test Taking Preferences
  static const String testTimerEnabled = 'test_timer_enabled';
  static const String testAutoSubmit = 'test_auto_submit';
  static const String testShowProgress = 'test_show_progress';
}