import '../data/models/TestAttempt.dart';
import '../data/models/User.dart';
import '../data/models/UserStats.dart';

class UserState {
  final User? user;
  final List<TestAttempt> recentAttempts;
  final UserStats? stats;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.recentAttempts = const [],
    this.stats,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    List<TestAttempt>? recentAttempts,
    UserStats? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserState(
      user: user ?? this.user,
      recentAttempts: recentAttempts ?? this.recentAttempts,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}