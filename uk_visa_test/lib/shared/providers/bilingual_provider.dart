// lib/shared/providers/bilingual_provider.dart - FIXED with Auto-Refresh
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/shared_prefs.dart';
import '../../data/states/BilingualState.dart';

final bilingualProvider = StateNotifierProvider<BilingualNotifier, BilingualState>((ref) {
  return BilingualNotifier(ref);
});

class BilingualNotifier extends StateNotifier<BilingualState> {
  BilingualNotifier(this._ref) : super(const BilingualState(
    isEnabled: false,
    primaryLanguage: 'en',
    secondaryLanguage: 'vi',
  )) {
    _loadSettings();
  }

  final Ref _ref;

  // Load settings from SharedPreferences
  void _loadSettings() {
    final prefs = SharedPrefsService.instance.getBilingualPreferences();
    state = BilingualState(
      isEnabled: prefs['enabled'] ?? false,
      primaryLanguage: 'en', // Always English
      secondaryLanguage: prefs['secondary_language'] ?? 'vi',
      isLoading: false,
    );
    print('🌍 Bilingual settings loaded: ${state.secondaryLanguage}');
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    await SharedPrefsService.instance.setBilingualPreferences({
      'enabled': state.isEnabled,
      'primary_language': 'en',
      'secondary_language': state.secondaryLanguage,
      'show_both_languages': true,
      'auto_translate': false,
    });
    print('💾 Bilingual settings saved: ${state.secondaryLanguage}');
  }

  // 🆕 NEW: Invalidate test-related providers when language changes
  void _invalidateTestProviders() {
    try {
      // Invalidate all test-related providers to trigger refresh
      _ref.invalidate(availableTestsProvider);
      _ref.invalidate(freeTestsProvider);

      // Note: Can't directly invalidate family providers, but they will refresh
      // when their dependencies (bilingual state) change

      print('🔄 Test providers invalidated due to language change');
    } catch (e) {
      print('⚠️ Error invalidating providers: $e');
    }
  }

  Future<void> toggleBilingual() async {
    final newState = state.copyWith(isEnabled: !state.isEnabled);
    state = newState;
    await _saveSettings();

    // Invalidate providers when toggling bilingual mode
    _invalidateTestProviders();
  }

  Future<void> setBilingualMode(bool isEnabled) async {
    if (state.isEnabled != isEnabled) {
      state = state.copyWith(isEnabled: isEnabled);
      await _saveSettings();

      // Invalidate providers when changing bilingual mode
      _invalidateTestProviders();
    }
  }

  // 🆕 ENHANCED: Support any secondary language with auto-refresh
  Future<void> setSecondaryLanguage(String language) async {
    if (ApiConstants.supportedSecondaryLanguages.contains(language) &&
        state.secondaryLanguage != language) {

      final previousLanguage = state.secondaryLanguage;
      state = state.copyWith(secondaryLanguage: language);
      await _saveSettings();

      print('🔄 Secondary language changed from $previousLanguage to $language');

      // 🚀 KEY FIX: Invalidate providers when language changes
      _invalidateTestProviders();
    } else {
      print('❌ Unsupported language or same language: $language');
    }
  }

  // Language helper methods
  String getCurrentSecondaryLanguage() => state.secondaryLanguage;

  String getSecondaryLanguageName() =>
      ApiConstants.getLanguageName(state.secondaryLanguage);

  String getSecondaryLanguageFlag() =>
      ApiConstants.getLanguageFlag(state.secondaryLanguage);

  bool isLanguageSupported(String language) =>
      ApiConstants.isSupportedLanguage(language);

  // Get available secondary languages
  List<Map<String, String>> getAvailableSecondaryLanguages() {
    return ApiConstants.supportedSecondaryLanguages.map((code) => {
      'code': code,
      'name': ApiConstants.getLanguageName(code),
      'flag': ApiConstants.getLanguageFlag(code),
    }).toList();
  }

  Future<void> resetToDefault() async {
    state = const BilingualState(
      isEnabled: false,
      primaryLanguage: 'en',
      secondaryLanguage: 'vi',
    );
    await _saveSettings();
    _invalidateTestProviders();
  }

  Future<void> syncWithServer() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement server sync for language preference
      // This would sync user's language preference with server
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// 🔄 UPDATED: Enhanced helper providers with proper dependencies
final shouldShowSecondaryLanguageProvider = Provider<bool>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.isEnabled;
});

final currentSecondaryLanguageProvider = Provider<String>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.secondaryLanguage;
});

final currentSecondaryLanguageNameProvider = Provider<String>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return ApiConstants.getLanguageName(bilingualState.secondaryLanguage);
});

final availableSecondaryLanguagesProvider = Provider<List<Map<String, String>>>((ref) {
  // This doesn't need to watch bilingual state since available languages don't change
  return ApiConstants.supportedSecondaryLanguages.map((code) => {
    'code': code,
    'name': ApiConstants.getLanguageName(code),
    'flag': ApiConstants.getLanguageFlag(code),
  }).toList();
});

// 🆕 NEW: Language change notifier for debugging
final languageChangeNotifierProvider = Provider<String>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  final languageInfo = '${bilingualState.isEnabled ? bilingualState.secondaryLanguage : 'disabled'}';

  // This will trigger whenever language state changes
  ref.listen(bilingualProvider, (previous, next) {
    if (previous?.secondaryLanguage != next.secondaryLanguage) {
      print('🌍 Language change detected: ${previous?.secondaryLanguage} → ${next.secondaryLanguage}');
    }
    if (previous?.isEnabled != next.isEnabled) {
      print('🔄 Bilingual mode changed: ${previous?.isEnabled} → ${next.isEnabled}');
    }
  });

  return languageInfo;
});

// Backward compatibility
@deprecated
final shouldShowVietnameseProvider = Provider<bool>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.isEnabled && bilingualState.secondaryLanguage == 'vi';
});

@deprecated
final isVietnameseEnabledProvider = Provider<bool>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.isEnabled && bilingualState.secondaryLanguage == 'vi';
});

// Forward declarations to avoid circular imports
// These will be imported from test_provider.dart
external Provider<AsyncValue<Map<String, List<dynamic>>>> availableTestsProvider;
external Provider<AsyncValue<List<dynamic>>> freeTestsProvider;