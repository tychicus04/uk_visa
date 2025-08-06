// lib/shared/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/shared_prefs.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() {
    final languageCode = SharedPrefsService.instance.getLanguageCode();
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await SharedPrefsService.instance.setLanguageCode(locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'en'
        ? const Locale('vi')
        : const Locale('en');
    await setLocale(newLocale);
  }
}

