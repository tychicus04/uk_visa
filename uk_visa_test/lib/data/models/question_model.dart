// lib/data/models/question_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'answer_model.dart';

part 'question_model.g.dart';

// lib/data/models/question_model.dart - Fixed version
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Question extends Equatable {
  final int id;
  final int testId;
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

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

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
