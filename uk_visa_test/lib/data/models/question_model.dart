// lib/data/models/question_model.dart - FIXED VERSION
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'answer_model.dart';

part 'question_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Question extends Equatable {
  final String id; // ✅ Changed to String
  final String testId; // ✅ Changed to String
  final String questionId;
  final String questionText;
  final String questionType;
  final String? explanation;
  final List<Answer> answers;
  final String createdAt;

  const Question({
    required this.id,
    required this.testId,
    required this.questionId,
    required this.questionText,
    required this.questionType,
    this.explanation,
    required this.answers,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // ✅ Safe type conversion with null safety
    return Question(
      id: json['id']?.toString() ?? '0',
      testId: json['test_id']?.toString() ?? '0',
      questionId: json['question_id']?.toString() ?? '',
      questionText: json['question_text']?.toString() ?? '',
      questionType: json['question_type']?.toString() ?? 'radio',
      explanation: json['explanation']?.toString(),
      answers: json['answers'] != null
          ? (json['answers'] as List).map((e) => Answer.fromJson(e)).toList()
          : <Answer>[],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  // ✅ Convenience getters for int values
  int get idInt => int.tryParse(id) ?? 0;
  int get testIdInt => int.tryParse(testId) ?? 0;

  // ✅ Helper to check question type
  bool get isRadio => questionType.toLowerCase() == 'radio';
  bool get isCheckbox => questionType.toLowerCase() == 'checkbox';

  // ✅ Helper to get correct answers
  List<Answer> get correctAnswers => answers.where((answer) => answer.isCorrect == true).toList();

  @override
  List<Object?> get props => [
    id,
    testId,
    questionId,
    questionText,
    questionType,
    explanation,
    answers,
    createdAt,
  ];
}