import 'UserAnswer.dart';

class TestAttempt {
  final int id;
  final int userId;
  final int testId;
  final int? score;
  final int? totalQuestions;
  final double? percentage;
  final int? timeTaken;
  final bool isPassed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? testTitle;
  final String? testNumber;
  final String? testType;
  final String? chapterName;
  final List<UserAnswer> answers;

  TestAttempt({
    required this.id,
    required this.userId,
    required this.testId,
    this.score,
    this.totalQuestions,
    this.percentage,
    this.timeTaken,
    required this.isPassed,
    required this.startedAt,
    this.completedAt,
    this.testTitle,
    this.testNumber,
    this.testType,
    this.chapterName,
    this.answers = const [],
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    return TestAttempt(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      testId: json['test_id'] ?? 0,
      score: json['score'],
      totalQuestions: json['total_questions'],
      percentage: json['percentage']?.toDouble(),
      timeTaken: json['time_taken'],
      isPassed: json['is_passed'] == 1 || json['is_passed'] == true,
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      testTitle: json['title'] ?? json['test_title'],
      testNumber: json['test_number'],
      testType: json['test_type'],
      chapterName: json['chapter_name'],
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => UserAnswer.fromJson(a)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'test_id': testId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': percentage,
      'time_taken': timeTaken,
      'is_passed': isPassed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'title': testTitle,
      'test_number': testNumber,
      'test_type': testType,
      'chapter_name': chapterName,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }

  // Computed properties
  bool get isCompleted => completedAt != null;
  String get formattedScore => score != null ? '$score/$totalQuestions' : '-';
  String get formattedPercentage => percentage != null ? '${percentage!.toStringAsFixed(1)}%' : '-';
  String get formattedTimeTaken {
    if (timeTaken == null) return '-';
    final minutes = timeTaken! ~/ 60;
    final seconds = timeTaken! % 60;
    return '${minutes}m ${seconds}s';
  }

  Duration? get duration {
    if (timeTaken == null) return null;
    return Duration(seconds: timeTaken!);
  }
}