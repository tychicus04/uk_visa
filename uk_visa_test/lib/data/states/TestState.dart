class TestState {

  const TestState({
    this.isLoading = false,
    this.error,
    this.currentAttemptId,
  });
  final bool isLoading;
  final String? error;
  final String? currentAttemptId;

  TestState copyWith({
    bool? isLoading,
    String? error,
    String? currentAttemptId,
  }) => TestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
    );

  int? get currentAttemptIdInt =>
      currentAttemptId != null ? int.tryParse(currentAttemptId!) : null;
}