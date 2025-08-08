// lib/data/models/answer_model.dart - FIXED VERSION
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Answer extends Equatable {
  final String id; // ✅ Changed to String
  final String questionId; // ✅ Changed to String
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

  factory Answer.fromJson(Map<String, dynamic> json) {
    // ✅ Safe type conversion with null safety
    return Answer(
      id: json['id']?.toString() ?? '0',
      questionId: json['question_id']?.toString() ?? '0',
      answerId: json['answer_id']?.toString() ?? '',
      answerText: json['answer_text']?.toString() ?? '',
      isCorrect: _parseBool(json['is_correct']),
      wasSelected: _parseBool(json['was_selected']),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  // ✅ Helper function to safely parse boolean
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }

  // ✅ Convenience getters for int values
  int get idInt => int.tryParse(id) ?? 0;
  int get questionIdInt => int.tryParse(questionId) ?? 0;

  // ✅ Helper properties
  bool get isCorrectAnswer => isCorrect == true;
  bool get wasSelectedByUser => wasSelected == true;

  // ✅ Create a copy with selection state
  Answer copyWithSelection(bool selected) {
    return Answer(
      id: id,
      questionId: questionId,
      answerId: answerId,
      answerText: answerText,
      isCorrect: isCorrect,
      wasSelected: selected,
      createdAt: createdAt,
    );
  }

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