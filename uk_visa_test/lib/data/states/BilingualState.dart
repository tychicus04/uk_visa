class BilingualState {
  const BilingualState({
    required this.isEnabled,
    required this.primaryLanguage,
    required this.secondaryLanguage,
    this.isLoading = false,
    this.error,
  });

  final bool isEnabled;
  final String primaryLanguage;
  final String secondaryLanguage;
  final bool isLoading;
  final String? error;

  BilingualState copyWith({
    bool? isEnabled,
    String? primaryLanguage,
    String? secondaryLanguage,
    bool? isLoading,
    String? error,
  }) => BilingualState(
    isEnabled: isEnabled ?? this.isEnabled,
    primaryLanguage: primaryLanguage ?? this.primaryLanguage,
    secondaryLanguage: secondaryLanguage ?? this.secondaryLanguage,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  @override
  String toString() => 'BilingualState(isEnabled: $isEnabled, primaryLanguage: $primaryLanguage, secondaryLanguage: $secondaryLanguage)';
}