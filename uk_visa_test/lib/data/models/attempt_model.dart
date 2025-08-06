// lib/data/models/attempt_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attempt_model.g.dart';

// lib/data/models/attempt_model.dart - Fixed version
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TestAttempt extends Equatable {
  final int id;
  final int userId;
  final int testId;
  final int? score;
  final int? totalQuestions;
  final double? percentage;
  final int? timeTaken;
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

  factory TestAttempt.fromJson(Map<String, dynamic> json) => _$TestAttemptFromJson(json);
  Map<String, dynamic> toJson() => _$TestAttemptToJson(this);

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

