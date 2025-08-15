import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/shared_prefs.dart';
import '../../data/states/BilingualState.dart';

final bilingualProvider = StateNotifierProvider<BilingualNotifier, BilingualState>((ref) {
  return BilingualNotifier();
});

class BilingualNotifier extends StateNotifier<BilingualState> {
  BilingualNotifier() : super(const BilingualState(
    isEnabled: false,
    primaryLanguage: 'en',
    secondaryLanguage: 'vi',
  )) {
    _loadSettings();
  }

  // 🆕 Load settings from SharedPreferences
  void _loadSettings() {
    final prefs = SharedPrefsService.instance.getBilingualPreferences();
    state = BilingualState(
      isEnabled: prefs['enabled'] ?? false,
      primaryLanguage: prefs['primary_language'] ?? 'en',
      secondaryLanguage: prefs['secondary_language'] ?? 'vi',
      isLoading: false,
    );
  }

  // 🆕 Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    await SharedPrefsService.instance.setBilingualPreferences({
      'enabled': state.isEnabled,
      'primary_language': state.primaryLanguage,
      'secondary_language': state.secondaryLanguage,
      'show_both_languages': true,
      'auto_translate': false,
    });
  }

  Future<void> toggleBilingual() async {
    state = state.copyWith(isEnabled: !state.isEnabled);
    await _saveSettings();
  }

  Future<void> setBilingualMode(bool isEnabled) async {
    state = state.copyWith(isEnabled: isEnabled);
    await _saveSettings();
  }

  Future<void> setPrimaryLanguage(String language) async {
    state = state.copyWith(primaryLanguage: language);
    await _saveSettings();
  }

  Future<void> setSecondaryLanguage(String language) async {
    state = state.copyWith(secondaryLanguage: language);
    await _saveSettings();
  }

  // 🆕 Reset to default settings
  Future<void> resetToDefault() async {
    state = const BilingualState(
      isEnabled: false,
      primaryLanguage: 'en',
      secondaryLanguage: 'vi',
    );
    await _saveSettings();
  }

  // 🆕 Load settings from server (future feature)
  Future<void> syncWithServer() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement server sync
      // final serverSettings = await api.getBilingualSettings();
      // state = state.copyWith(
      //   isEnabled: serverSettings.isEnabled,
      //   isLoading: false,
      // );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Helper providers
final shouldShowVietnameseProvider = Provider<bool>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.isEnabled;
});

final currentLanguageProvider = Provider<String>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.isEnabled ? 'bilingual' : bilingualState.primaryLanguage;
});

final isVietnameseEnabledProvider = Provider<bool>((ref) {
  final bilingualState = ref.watch(bilingualProvider);
  return bilingualState.isEnabled && bilingualState.secondaryLanguage == 'vi';
});