class UserStats {
  final int totalAttempts;
  final int passedAttempts;
  final double averageScore;
  final double bestScore;
  final int totalTestsCompleted;
  final int streak;

  UserStats({
    required this.totalAttempts,
    required this.passedAttempts,
    required this.averageScore,
    required this.bestScore,
    required this.totalTestsCompleted,
    required this.streak,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalAttempts: json['total_attempts'] ?? 0,
      passedAttempts: json['passed_attempts'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      bestScore: (json['best_score'] ?? 0.0).toDouble(),
      totalTestsCompleted: json['total_tests_completed'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_attempts': totalAttempts,
      'passed_attempts': passedAttempts,
      'average_score': averageScore,
      'best_score': bestScore,
      'total_tests_completed': totalTestsCompleted,
      'streak': streak,
    };
  }

  // Computed properties
  double get passRate => totalAttempts > 0 ? (passedAttempts / totalAttempts) * 100 : 0.0;
  bool get hasCompletedTests => totalTestsCompleted > 0;
  String get performanceLevel {
    if (averageScore >= 90) return 'excellent';
    if (averageScore >= 80) return 'good';
    if (averageScore >= 70) return 'average';
    return 'needs_improvement';
  }
}