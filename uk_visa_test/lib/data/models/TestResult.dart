// Test Result Model
class TestResult {
  final int score;
  final int totalQuestions;
  final double percentage;
  final bool isPassed;
  final int timeTaken;
  final String testTitle;
  final String testNumber;
  final DateTime completedAt;

  TestResult({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.isPassed,
    required this.timeTaken,
    required this.testTitle,
    required this.testNumber,
    required this.completedAt,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? json;
    final test = json['test'] ?? {};

    return TestResult(
      score: result['score'] ?? 0,
      totalQuestions: result['total_questions'] ?? 0,
      percentage: (result['percentage'] ?? 0.0).toDouble(),
      isPassed: result['is_passed'] == 1 || result['is_passed'] == true,
      timeTaken: result['time_taken'] ?? 0,
      testTitle: test['title'] ?? '',
      testNumber: test['test_number'] ?? '',
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Computed properties
  String get formattedScore => '$score/$totalQuestions';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
  String get formattedTimeTaken {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }

  String get resultStatus {
    if (isPassed) return 'passed';
    return 'failed';
  }

  String get performanceLevel {
    if (percentage >= 90) return 'excellent';
    if (percentage >= 80) return 'good';
    if (percentage >= 75) return 'pass';
    return 'fail';
  }
}