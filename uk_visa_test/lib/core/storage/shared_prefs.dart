import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  static SharedPrefsService get instance => _instance;
  SharedPrefsService._internal();

  late SharedPreferences _prefs;

  void setSharedPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  // Theme
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageKeys.themeMode, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode);
  }

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
    await _prefs.setString(StorageKeys.primaryLanguage, language);
  }

  String getPrimaryLanguage() {
    return _prefs.getString(StorageKeys.primaryLanguage) ?? 'en';
  }

  Future<void> setSecondaryLanguage(String language) async {
    await _prefs.setString(StorageKeys.secondaryLanguage, language);
  }

  String getSecondaryLanguage() {
    return _prefs.getString(StorageKeys.secondaryLanguage) ?? 'vi';
  }

  Future<void> setShowBothLanguages(bool show) async {
    await _prefs.setBool(StorageKeys.showBothLanguages, show);
  }

  bool getShowBothLanguages() {
    return _prefs.getBool(StorageKeys.showBothLanguages) ?? true;
  }

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

  // 🆕 NEW: Get all bilingual preferences at once
  Map<String, dynamic> getBilingualPreferences() {
    return {
      'enabled': getBilingualEnabled(),
      'primary_language': getPrimaryLanguage(),
      'secondary_language': getSecondaryLanguage(),
      'show_both_languages': getShowBothLanguages(),
      'auto_translate': getAutoTranslate(),
    };
  }

  // 🆕 NEW: Set all bilingual preferences at once
  Future<void> setBilingualPreferences(Map<String, dynamic> prefs) async {
    await setBilingualEnabled(prefs['enabled'] ?? false);
    await setPrimaryLanguage(prefs['primary_language'] ?? 'en');
    await setSecondaryLanguage(prefs['secondary_language'] ?? 'vi');
    await setShowBothLanguages(prefs['show_both_languages'] ?? true);
    await setAutoTranslate(prefs['auto_translate'] ?? false);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}