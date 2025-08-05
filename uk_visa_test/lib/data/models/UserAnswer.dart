import 'dart:convert';
import 'Answer.dart';

class UserAnswer {
  final int id;
  final int attemptId;
  final int questionId;
  final List<String> selectedAnswerIds;
  final bool isCorrect;
  final DateTime answeredAt;
  final String? questionText;
  final String? questionType;
  final List<Answer>? answerDetails;

  UserAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswerIds,
    required this.isCorrect,
    required this.answeredAt,
    this.questionText,
    this.questionType,
    this.answerDetails,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      id: json['id'] ?? 0,
      attemptId: json['attempt_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      selectedAnswerIds: json['selected_answer_ids'] is String
          ? jsonDecode(json['selected_answer_ids']).cast<String>()
          : (json['selected_answer_ids'] as List? ?? []).cast<String>(),
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      answeredAt: DateTime.parse(json['answered_at'] ?? DateTime.now().toIso8601String()),
      questionText: json['question_text'],
      questionType: json['question_type'],
      answerDetails: json['answer_details'] != null
          ? (json['answer_details'] as List).map((a) => Answer.fromJson(a)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'selected_answer_ids': selectedAnswerIds,
      'is_correct': isCorrect,
      'answered_at': answeredAt.toIso8601String(),
      'question_text': questionText,
      'question_type': questionType,
      'answer_details': answerDetails?.map((a) => a.toJson()).toList(),
    };
  }
}
