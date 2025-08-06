// lib/core/storage/shared_prefs.dart
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
}