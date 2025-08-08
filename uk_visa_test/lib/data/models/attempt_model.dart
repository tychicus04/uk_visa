// lib/data/models/attempt_model.dart - FIXED VERSION
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attempt_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TestAttempt extends Equatable {
  final String id; // ✅ Changed to String
  final String userId; // ✅ Changed to String
  final String testId; // ✅ Changed to String
  final String? score; // ✅ Changed to String
  final String? totalQuestions; // ✅ Changed to String
  final double? percentage;
  final String? timeTaken; // ✅ Changed to String
  final bool isPassed;
  final String startedAt;
  final String? completedAt;
  final String? title;
  final String? testNumber;
  final String? testType;
  final String? chapterName;

  const TestAttempt({
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
    this.title,
    this.testNumber,
    this.testType,
    this.chapterName,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    // ✅ Safe type conversion with null safety
    return TestAttempt(
      id: json['id']?.toString() ?? '0',
      userId: json['user_id']?.toString() ?? '0',
      testId: json['test_id']?.toString() ?? '0',
      score: json['score']?.toString(),
      totalQuestions: json['total_questions']?.toString(),
      percentage: _parseDouble(json['percentage']),
      timeTaken: json['time_taken']?.toString(),
      isPassed: _parseBool(json['is_passed']) ?? false,
      startedAt: json['started_at']?.toString() ?? '',
      completedAt: json['completed_at']?.toString(),
      title: json['title']?.toString(),
      testNumber: json['test_number']?.toString(),
      testType: json['test_type']?.toString(),
      chapterName: json['chapter_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$TestAttemptToJson(this);

  // ✅ Helper function to safely parse boolean
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // ✅ Helper function to safely parse double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ✅ Convenience getters for int values
  int get idInt => int.tryParse(id) ?? 0;
  int get userIdInt => int.tryParse(userId) ?? 0;
  int get testIdInt => int.tryParse(testId) ?? 0;
  int get scoreInt => int.tryParse(score ?? '0') ?? 0;
  int get totalQuestionsInt => int.tryParse(totalQuestions ?? '24') ?? 24;
  int get timeTakenInt => int.tryParse(timeTaken ?? '0') ?? 0;

  // ✅ Helper properties
  bool get isCompleted => completedAt != null;
  bool get isInProgress => completedAt == null;

  // ✅ Get formatted time taken
  String get formattedTimeTaken {
    final seconds = timeTakenInt;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  // ✅ Get display title
  String get displayTitle => title ?? 'Test $testNumber';

  // ✅ Get score display
  String get scoreDisplay => '$scoreInt/$totalQuestionsInt';

  // ✅ Get percentage display
  String get percentageDisplay {
    if (percentage == null) return 'N/A';
    return '${percentage!.toInt()}%';
  }

  // ✅ Get result status
  String get resultStatus => isPassed ? 'Passed' : 'Failed';

  // ✅ Get result color indicator
  String get resultColor => isPassed ? 'success' : 'error';

  // ✅ Get grade based on percentage
  String get grade {
    if (percentage == null) return 'N/A';
    if (percentage! >= 90) return 'A+';
    if (percentage! >= 80) return 'A';
    if (percentage! >= 75) return 'B+';
    if (percentage! >= 70) return 'B';
    if (percentage! >= 60) return 'C';
    return 'F';
  }

  // ✅ Check if this is a high score
  bool get isHighScore => (percentage ?? 0) >= 90;

  // ✅ Calculate accuracy
  double get accuracy => totalQuestionsInt > 0 ? (scoreInt / totalQuestionsInt) * 100 : 0;

  // ✅ Get time efficiency (questions per minute)
  double get questionsPerMinute {
    final minutes = timeTakenInt / 60;
    return minutes > 0 ? totalQuestionsInt / minutes : 0;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    testId,
    score,
    totalQuestions,
    percentage,
    timeTaken,
    isPassed,
    startedAt,
    completedAt,
    title,
    testNumber,
    testType,
    chapterName,
  ];
}