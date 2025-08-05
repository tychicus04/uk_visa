import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/User.dart';
import 'logger.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainItemAccessibility.first_unlock_this_device,
    ),
  );

  // ==========================================================================
  // TOKEN MANAGEMENT
  // ==========================================================================

  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // ==========================================================================
  // USER DATA MANAGEMENT
  // ==========================================================================

  static Future<void> saveUser(User user) async {
    await _storage.write(key: AppConstants.userKey, value: user.toJsonString());
  }

  static Future<User?> getUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson != null) {
      try {
        return User.fromJsonString(userJson);
      } catch (e) {
        Logger.error('Failed to parse user data: $e');
        await _storage.delete(key: AppConstants.userKey);
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  // ==========================================================================
  // PREFERENCES MANAGEMENT
  // ==========================================================================

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, theme);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.themeKey) ?? 'system';
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  // ==========================================================================
  // CACHE MANAGEMENT
  // ==========================================================================

  static Future<void> saveCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_$key', jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = prefs.getString('cache_$key');
    if (cacheData != null) {
      try {
        return jsonDecode(cacheData);
      } catch (e) {
        Logger.error('Failed to parse cache data for $key: $e');
        await prefs.remove('cache_$key');
        return null;
      }
    }
    return null;
  }

  static Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
  }

  // ==========================================================================
  // CLEAR ALL DATA
  // ==========================================================================

  static Future<void> clear() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();

    // Keep language and theme settings
    final language = prefs.getString(AppConstants.languageKey);
    final theme = prefs.getString(AppConstants.themeKey);

    await prefs.clear();

    // Restore language and theme
    if (language != null) {
      await prefs.setString(AppConstants.languageKey, language);
    }
    if (theme != null) {
      await prefs.setString(AppConstants.themeKey, theme);
    }
  }

  // ==========================================================================
  // BIOMETRIC AUTHENTICATION (if needed)
  // ==========================================================================

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }
}