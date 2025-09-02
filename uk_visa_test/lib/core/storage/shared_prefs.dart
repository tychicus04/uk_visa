import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

class SharedPrefsService {
  SharedPrefsService._internal();
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  static SharedPrefsService get instance => _instance;

  late SharedPreferences _prefs;

  void setSharedPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  // Theme
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageKeys.themeMode, mode);
  }

  String? getThemeMode() => _prefs.getString(StorageKeys.themeMode);

  // Language
  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(StorageKeys.languageCode, code);
  }

  String? getLanguageCode() {
    return _prefs.getString(StorageKeys.languageCode);
  }

  // 🆕 NEW: Bilingual Settings
  Future<void> setBilingualEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.bilingualEnabled, enabled);
  }

  bool getBilingualEnabled() {
    return _prefs.getBool(StorageKeys.bilingualEnabled) ?? false;
  }

  Future<void> setPrimaryLanguage(String language) async {
    // Primary is always English in this app
    await _prefs.setString(StorageKeys.primaryLanguage, 'en');
  }

  String getPrimaryLanguage() => 'en';

  Future<void> setSecondaryLanguage(String language) async {
    if (ApiConstants.supportedSecondaryLanguages.contains(language)) {
      await _prefs.setString(StorageKeys.secondaryLanguage, language);
      await _prefs.setString(StorageKeys.lastUsedSecondaryLanguage, language);
    }
  }

  String getSecondaryLanguage() {
    final stored = _prefs.getString(StorageKeys.secondaryLanguage);
    if (stored != null && ApiConstants.supportedSecondaryLanguages.contains(stored)) {
      return stored;
    }
    return 'vi'; // Default to Vietnamese
  }

  Future<void> setShowBothLanguages(bool show) async {
    await _prefs.setBool(StorageKeys.showBothLanguages, show);
  }

  bool getShowBothLanguages() => _prefs.getBool(StorageKeys.showBothLanguages) ?? true;

  Future<void> setAutoTranslate(bool auto) async {
    await _prefs.setBool(StorageKeys.autoTranslate, auto);
  }

  bool getAutoTranslate() {
    return _prefs.getBool(StorageKeys.autoTranslate) ?? false;
  }

  // User Preferences
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.notificationsEnabled, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  Future<void> setPracticeTime(String time) async {
    await _prefs.setString(StorageKeys.practiceTime, time);
  }

  String getPracticeTime() {
    return _prefs.getString(StorageKeys.practiceTime) ?? '10:00 AM';
  }

  // Onboarding
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs.setBool(StorageKeys.isFirstLaunch, isFirst);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // 🆕 NEW: Get last used secondary language
  String getLastUsedSecondaryLanguage() => _prefs.getString(StorageKeys.lastUsedSecondaryLanguage) ?? 'vi';

  // 🆕 NEW: Language preference helpers
  Future<void> setLanguagePreference(String primaryLang, String secondaryLang) async {
    await setPrimaryLanguage(primaryLang);
    await setSecondaryLanguage(secondaryLang);
  }

  Map<String, String> getLanguagePreference() => {
      'primary': getPrimaryLanguage(),
      'secondary': getSecondaryLanguage(),
    };

  // 🔄 UPDATED: Enhanced bilingual preferences
  Map<String, dynamic> getBilingualPreferences() => {
      'enabled': getBilingualEnabled(),
      'primary_language': getPrimaryLanguage(),
      'secondary_language': getSecondaryLanguage(),
      'show_both_languages': getShowBothLanguages(),
      'auto_translate': getAutoTranslate(),
      'last_used_secondary': getLastUsedSecondaryLanguage(),
    };

  Future<void> setBilingualPreferences(Map<String, dynamic> prefs) async {
    await setBilingualEnabled(prefs['enabled'] ?? false);
    await setPrimaryLanguage(prefs['primary_language'] ?? 'en');
    await setSecondaryLanguage(prefs['secondary_language'] ?? 'vi');
    await setShowBothLanguages(prefs['show_both_languages'] ?? true);
    await setAutoTranslate(prefs['auto_translate'] ?? false);
  }
}