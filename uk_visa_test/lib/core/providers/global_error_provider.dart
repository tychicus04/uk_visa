import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalErrorProvider = StateNotifierProvider<GlobalErrorNotifier, String?>((ref) => GlobalErrorNotifier());

class GlobalErrorNotifier extends StateNotifier<String?> {
  GlobalErrorNotifier() : super(null);

  void showError(String message) {
    state = message;
  }

  void clearError() {
    state = null;
  }
}