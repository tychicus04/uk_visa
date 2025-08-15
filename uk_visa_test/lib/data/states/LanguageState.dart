import 'dart:ui';

class LanguageState {
  const LanguageState({
    required this.currentLocale,
    this.isLoading = false,
    this.error,
  });
  final Locale currentLocale;
  final bool isLoading;
  final String? error;

  LanguageState copyWith({
    Locale? currentLocale,
    bool? isLoading,
    String? error,
  }) => LanguageState(
    currentLocale: currentLocale ?? this.currentLocale,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}