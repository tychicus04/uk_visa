// lib/data/models/attempt_model.dart - UPDATED WITH COMPLETE MULTI-LANGUAGE SUPPORT
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/api_constants.dart';

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

  // 🔄 DEPRECATED: Keep for backward compatibility
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
    print('🔄 TestAttempt.fromJson: Parsing JSON data...');
    print('   Raw JSON: $json');
    
    final attempt = TestAttempt(
      id: json['id']?.toString() ?? '0',
      userId: json['user_id']?.toString() ?? '0',
      testId: json['test_id']?.toString() ?? '0',
      score: json['score']?.toString(),
      totalQuestions: json['total_questions']?.toString(),
      percentage: _parseDouble(json['percentage']),
      timeTaken: json['time_taken']?.toString(),
      isPassed: _parseBool(json['is_passed'] ?? json['passed']),
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
    
    print('✅ TestAttempt parsed: id=${attempt.id}, score=${attempt.score}, total=${attempt.totalQuestions}, percentage=${attempt.percentage}%, passed=${attempt.isPassed}');
    return attempt;
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
  bool get isTimed {
    final t = testType?.toLowerCase();
    return t == 'exam' || t == 'comprehensive';
  }

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

// ✅ ENHANCED: Model for individual answer in review with COMPLETE multi-language support
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AttemptAnswer extends Equatable {
  final String questionId;
  final String? questionText;

  // 🆕 ENHANCED: Complete multi-language support for questions
  final String? questionTextVi;
  final String? questionTextPl;
  final String? questionTextPa;
  final String? questionTextUr;
  final String? questionTextRo;
  final String? questionTextEs;
  final String? questionTextPt;
  final String? questionTextAr;

  final String? questionType;
  final String? explanation;

  // 🆕 ENHANCED: Complete multi-language support for explanations
  final String? explanationVi;
  final String? explanationPl;
  final String? explanationPa;
  final String? explanationUr;
  final String? explanationRo;
  final String? explanationEs;
  final String? explanationPt;
  final String? explanationAr;

  final List<String>? selectedAnswerIds;
  final bool isCorrect;
  final List<AnswerOption>? answerDetails;

  const AttemptAnswer({
    required this.questionId,
    this.questionText,
    this.questionTextVi,
    this.questionTextPl,
    this.questionTextPa,
    this.questionTextUr,
    this.questionTextRo,
    this.questionTextEs,
    this.questionTextPt,
    this.questionTextAr,
    this.questionType,
    this.explanation,
    this.explanationVi,
    this.explanationPl,
    this.explanationPa,
    this.explanationUr,
    this.explanationRo,
    this.explanationEs,
    this.explanationPt,
    this.explanationAr,
    this.selectedAnswerIds,
    required this.isCorrect,
    this.answerDetails,
  });

  factory AttemptAnswer.fromJson(Map<String, dynamic> json) {
    return AttemptAnswer(
      questionId: json['question_id']?.toString() ?? '0',
      questionText: json['question_text'] as String?,
      questionTextVi: json['question_text_vi'] as String?,
      questionTextPl: json['question_text_pl'] as String?,
      questionTextPa: json['question_text_pa'] as String?,
      questionTextUr: json['question_text_ur'] as String?,
      questionTextRo: json['question_text_ro'] as String?,
      questionTextEs: json['question_text_es'] as String?,
      questionTextPt: json['question_text_pt'] as String?,
      questionTextAr: json['question_text_ar'] as String?,
      questionType: json['question_type'] as String?,
      explanation: json['explanation'] as String?,
      explanationVi: json['explanation_vi'] as String?,
      explanationPl: json['explanation_pl'] as String?,
      explanationPa: json['explanation_pa'] as String?,
      explanationUr: json['explanation_ur'] as String?,
      explanationRo: json['explanation_ro'] as String?,
      explanationEs: json['explanation_es'] as String?,
      explanationPt: json['explanation_pt'] as String?,
      explanationAr: json['explanation_ar'] as String?,
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

  // 🆕 NEW: Dynamic language support methods
  String getQuestionText({String? languageCode}) {
    if (languageCode == null || languageCode == 'en') {
      return questionText ?? '';
    }

    switch (languageCode) {
      case 'vi': return questionTextVi?.isNotEmpty == true ? questionTextVi! : (questionText ?? '');
      case 'pl': return questionTextPl?.isNotEmpty == true ? questionTextPl! : (questionText ?? '');
      case 'pa': return questionTextPa?.isNotEmpty == true ? questionTextPa! : (questionText ?? '');
      case 'ur': return questionTextUr?.isNotEmpty == true ? questionTextUr! : (questionText ?? '');
      case 'ro': return questionTextRo?.isNotEmpty == true ? questionTextRo! : (questionText ?? '');
      case 'es': return questionTextEs?.isNotEmpty == true ? questionTextEs! : (questionText ?? '');
      case 'pt': return questionTextPt?.isNotEmpty == true ? questionTextPt! : (questionText ?? '');
      case 'ar': return questionTextAr?.isNotEmpty == true ? questionTextAr! : (questionText ?? '');
      default: return questionText ?? '';
    }
  }

  String getExplanation({String? languageCode}) {
    if (languageCode == null || languageCode == 'en') {
      return explanation ?? '';
    }

    switch (languageCode) {
      case 'vi': return explanationVi?.isNotEmpty == true ? explanationVi! : (explanation ?? '');
      case 'pl': return explanationPl?.isNotEmpty == true ? explanationPl! : (explanation ?? '');
      case 'pa': return explanationPa?.isNotEmpty == true ? explanationPa! : (explanation ?? '');
      case 'ur': return explanationUr?.isNotEmpty == true ? explanationUr! : (explanation ?? '');
      case 'ro': return explanationRo?.isNotEmpty == true ? explanationRo! : (explanation ?? '');
      case 'es': return explanationEs?.isNotEmpty == true ? explanationEs! : (explanation ?? '');
      case 'pt': return explanationPt?.isNotEmpty == true ? explanationPt! : (explanation ?? '');
      case 'ar': return explanationAr?.isNotEmpty == true ? explanationAr! : (explanation ?? '');
      default: return explanation ?? '';
    }
  }

  bool hasQuestionTranslation(String languageCode) {
    switch (languageCode) {
      case 'en': return questionText?.isNotEmpty == true;
      case 'vi': return questionTextVi?.isNotEmpty == true;
      case 'pl': return questionTextPl?.isNotEmpty == true;
      case 'pa': return questionTextPa?.isNotEmpty == true;
      case 'ur': return questionTextUr?.isNotEmpty == true;
      case 'ro': return questionTextRo?.isNotEmpty == true;
      case 'es': return questionTextEs?.isNotEmpty == true;
      case 'pt': return questionTextPt?.isNotEmpty == true;
      case 'ar': return questionTextAr?.isNotEmpty == true;
      default: return false;
    }
  }

  bool hasExplanationTranslation(String languageCode) {
    switch (languageCode) {
      case 'en': return explanation?.isNotEmpty == true;
      case 'vi': return explanationVi?.isNotEmpty == true;
      case 'pl': return explanationPl?.isNotEmpty == true;
      case 'pa': return explanationPa?.isNotEmpty == true;
      case 'ur': return explanationUr?.isNotEmpty == true;
      case 'ro': return explanationRo?.isNotEmpty == true;
      case 'es': return explanationEs?.isNotEmpty == true;
      case 'pt': return explanationPt?.isNotEmpty == true;
      case 'ar': return explanationAr?.isNotEmpty == true;
      default: return false;
    }
  }

  @override
  List<Object?> get props => [
    questionId, questionText, questionTextVi, questionTextPl, questionTextPa,
    questionTextUr, questionTextRo, questionTextEs, questionTextPt, questionTextAr,
    questionType, explanation, explanationVi, explanationPl, explanationPa,
    explanationUr, explanationRo, explanationEs, explanationPt, explanationAr,
    selectedAnswerIds, isCorrect, answerDetails,
  ];
}

// ✅ ENHANCED: Model for answer options in review with COMPLETE multi-language support
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnswerOption extends Equatable {
  final String answerId;
  final String? answerText;

  // 🆕 ENHANCED: Complete multi-language support for answers
  final String? answerTextVi;
  final String? answerTextPl;
  final String? answerTextPa;
  final String? answerTextUr;
  final String? answerTextRo;
  final String? answerTextEs;
  final String? answerTextPt;
  final String? answerTextAr;

  final bool isCorrect;
  final bool wasSelected;

  const AnswerOption({
    required this.answerId,
    this.answerText,
    this.answerTextVi,
    this.answerTextPl,
    this.answerTextPa,
    this.answerTextUr,
    this.answerTextRo,
    this.answerTextEs,
    this.answerTextPt,
    this.answerTextAr,
    required this.isCorrect,
    required this.wasSelected,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      answerId: json['answer_id']?.toString() ?? '0',
      answerText: json['answer_text'] as String?,
      answerTextVi: json['answer_text_vi'] as String?,
      answerTextPl: json['answer_text_pl'] as String?,
      answerTextPa: json['answer_text_pa'] as String?,
      answerTextUr: json['answer_text_ur'] as String?,
      answerTextRo: json['answer_text_ro'] as String?,
      answerTextEs: json['answer_text_es'] as String?,
      answerTextPt: json['answer_text_pt'] as String?,
      answerTextAr: json['answer_text_ar'] as String?,
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      wasSelected: json['was_selected'] == 1 || json['was_selected'] == true,
    );
  }

  Map<String, dynamic> toJson() => _$AnswerOptionToJson(this);

  // 🆕 NEW: Dynamic language support methods
  String getAnswerText({String? languageCode}) {
    if (languageCode == null || languageCode == 'en') {
      return answerText ?? '';
    }

    switch (languageCode) {
      case 'vi': return answerTextVi?.isNotEmpty == true ? answerTextVi! : (answerText ?? '');
      case 'pl': return answerTextPl?.isNotEmpty == true ? answerTextPl! : (answerText ?? '');
      case 'pa': return answerTextPa?.isNotEmpty == true ? answerTextPa! : (answerText ?? '');
      case 'ur': return answerTextUr?.isNotEmpty == true ? answerTextUr! : (answerText ?? '');
      case 'ro': return answerTextRo?.isNotEmpty == true ? answerTextRo! : (answerText ?? '');
      case 'es': return answerTextEs?.isNotEmpty == true ? answerTextEs! : (answerText ?? '');
      case 'pt': return answerTextPt?.isNotEmpty == true ? answerTextPt! : (answerText ?? '');
      case 'ar': return answerTextAr?.isNotEmpty == true ? answerTextAr! : (answerText ?? '');
      default: return answerText ?? '';
    }
  }

  bool hasAnswerTranslation(String languageCode) {
    switch (languageCode) {
      case 'en': return answerText?.isNotEmpty == true;
      case 'vi': return answerTextVi?.isNotEmpty == true;
      case 'pl': return answerTextPl?.isNotEmpty == true;
      case 'pa': return answerTextPa?.isNotEmpty == true;
      case 'ur': return answerTextUr?.isNotEmpty == true;
      case 'ro': return answerTextRo?.isNotEmpty == true;
      case 'es': return answerTextEs?.isNotEmpty == true;
      case 'pt': return answerTextPt?.isNotEmpty == true;
      case 'ar': return answerTextAr?.isNotEmpty == true;
      default: return false;
    }
  }

  @override
  List<Object?> get props => [
    answerId, answerText, answerTextVi, answerTextPl, answerTextPa,
    answerTextUr, answerTextRo, answerTextEs, answerTextPt, answerTextAr,
    isCorrect, wasSelected,
  ];
}