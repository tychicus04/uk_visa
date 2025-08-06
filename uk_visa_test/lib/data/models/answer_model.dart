// lib/data/models/answer_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

// lib/data/models/answer_model.dart - Fixed version
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Answer extends Equatable {
  final int id;
  final int questionId;
  final String answerId;
  final String answerText;
  final bool? isCorrect;
  final bool? wasSelected;
  final String? createdAt;

  const Answer({
    required this.id,
    required this.questionId,
    required this.answerId,
    required this.answerText,
    this.isCorrect,
    this.wasSelected,
    this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  @override
  List<Object?> get props => [
    id,
    questionId,
    answerId,
    answerText,
    isCorrect,
    wasSelected,
    createdAt,
  ];
}

