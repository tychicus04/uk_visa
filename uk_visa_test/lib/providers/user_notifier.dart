import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/TestAttempt.dart';
import '../data/models/UserStats.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';
import 'UserState.dart';

// =============================================================================
// USER NOTIFIER
// =============================================================================

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  Future<void> loadRecentAttempts({int limit = 10}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final attempts = await ApiService.getAttemptHistory(page: 1, limit: limit);

      state = state.copyWith(
        recentAttempts: attempts,
        isLoading: false,
      );

      Logger.info('Loaded ${attempts.length} recent attempts');
    } catch (e) {
      Logger.error('Failed to load recent attempts', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateUserStats(UserStats stats) {
    state = state.copyWith(stats: stats);
  }

  void addAttempt(TestAttempt attempt) {
    final updatedAttempts = [attempt, ...state.recentAttempts];
    state = state.copyWith(recentAttempts: updatedAttempts);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
