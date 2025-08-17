// lib/data/models/attempt_model.dart - UPDATED WITH REVIEW SUPPORT
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attempt_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TestAttempt extends Equatable {
  final String id;
  final String userId;
  final String testId;
  final String? score;
  final String? totalQuestions;
  final double? percentage;
  final String? timeTaken;
  final bool isPassed;
  final String startedAt;
  final String? completedAt;
  final String? title;
  final String? testNumber;
  final String? testType;
  final String? chapterName;
  final String? questionTextVi;
  final String? explanationVi;

  // ✅ NEW: Fields for review answers
  final List<AttemptAnswer>? answers;
  final Map<String, dynamic>? responseMetadata;

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
    this.questionTextVi,
    this.explanationVi,
    this.answers,
    this.responseMetadata,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
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
      questionTextVi: json['question_text_vi'] as String?,
      explanationVi: json['explanation_vi'] as String?,
      answers: json['answers'] != null
          ? (json['answers'] as List).map((e) => AttemptAnswer.fromJson(e)).toList()
          : null,
      responseMetadata: json['response_metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => _$TestAttemptToJson(this);

  // Helper functions
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Convenience getters
  int get idInt => int.tryParse(id) ?? 0;
  int get userIdInt => int.tryParse(userId) ?? 0;
  int get testIdInt => int.tryParse(testId) ?? 0;
  int get scoreInt => int.tryParse(score ?? '0') ?? 0;
  int get totalQuestionsInt => int.tryParse(totalQuestions ?? '24') ?? 24;
  int get timeTakenInt => int.tryParse(timeTaken ?? '0') ?? 0;

  // ✅ NEW: Alias for compatibility
  String? get testTitle => title;

  // Helper properties
  bool get isCompleted => completedAt != null;
  bool get isInProgress => completedAt == null;

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

  String get displayTitle => title ?? 'Test $testNumber';
  String get scoreDisplay => '$scoreInt/$totalQuestionsInt';
  String get percentageDisplay {
    if (percentage == null) return 'N/A';
    return '${percentage!.toInt()}%';
  }

  String get resultStatus => isPassed ? 'Passed' : 'Failed';
  String get resultColor => isPassed ? 'success' : 'error';

  String get grade {
    if (percentage == null) return 'N/A';
    if (percentage! >= 90) return 'A+';
    if (percentage! >= 80) return 'A';
    if (percentage! >= 75) return 'B+';
    if (percentage! >= 70) return 'B';
    if (percentage! >= 60) return 'C';
    return 'F';
  }

  bool get isHighScore => (percentage ?? 0) >= 90;
  double get accuracy => totalQuestionsInt > 0 ? (scoreInt / totalQuestionsInt) * 100 : 0;

  double get questionsPerMinute {
    final minutes = timeTakenInt / 60;
    return minutes > 0 ? totalQuestionsInt / minutes : 0;
  }

  @override
  List<Object?> get props => [
    id, userId, testId, score, totalQuestions, percentage, timeTaken,
    isPassed, startedAt, completedAt, title, testNumber, testType,
    chapterName, questionTextVi, explanationVi, answers, responseMetadata,
  ];
}

// ✅ NEW: Model for individual answer in review
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AttemptAnswer extends Equatable {
  final String questionId;
  final String? questionText;
  final String? questionTextVi;
  final String? questionType;
  final String? explanation;
  final String? explanationVi;
  final List<String>? selectedAnswerIds;
  final bool isCorrect;
  final List<AnswerOption>? answerDetails;

  const AttemptAnswer({
    required this.questionId,
    this.questionText,
    this.questionTextVi,
    this.questionType,
    this.explanation,
    this.explanationVi,
    this.selectedAnswerIds,
    required this.isCorrect,
    this.answerDetails,
  });

  factory AttemptAnswer.fromJson(Map<String, dynamic> json) {
    return AttemptAnswer(
      questionId: json['question_id']?.toString() ?? '0',
      questionText: json['question_text'] as String?,
      questionTextVi: json['question_text_vi'] as String?,
      questionType: json['question_type'] as String?,
      explanation: json['explanation'] as String?,
      explanationVi: json['explanation_vi'] as String?,
      selectedAnswerIds: json['selected_answer_ids'] != null
          ? List<String>.from(json['selected_answer_ids'])
          : null,
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      answerDetails: json['answer_details'] != null
          ? (json['answer_details'] as List).map((e) => AnswerOption.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$AttemptAnswerToJson(this);

  @override
  List<Object?> get props => [
    questionId, questionText, questionTextVi, questionType,
    explanation, explanationVi, selectedAnswerIds, isCorrect, answerDetails,
  ];
}

// ✅ NEW: Model for answer options in review
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnswerOption extends Equatable {
  final String answerId;
  final String? answerText;
  final String? answerTextVi;
  final bool isCorrect;
  final bool wasSelected;

  const AnswerOption({
    required this.answerId,
    this.answerText,
    this.answerTextVi,
    required this.isCorrect,
    required this.wasSelected,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      answerId: json['answer_id']?.toString() ?? '0',
      answerText: json['answer_text'] as String?,
      answerTextVi: json['answer_text_vi'] as String?,
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      wasSelected: json['was_selected'] == 1 || json['was_selected'] == true,
    );
  }

  Map<String, dynamic> toJson() => _$AnswerOptionToJson(this);

  @override
  List<Object?> get props => [answerId, answerText, answerTextVi, isCorrect, wasSelected];
}