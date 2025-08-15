import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Answer extends Equatable {

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
      id: json['id']?.toString() ?? '0',
      questionId: json['question_id']?.toString() ?? '0',
      answerId: json['answer_id']?.toString() ?? '',
      answerText: json['answer_text']?.toString() ?? '',
      answerTextVi: json['answer_text_vi']?.toString(),
      isCorrect: _parseBool(json['is_correct']),
      wasSelected: _parseBool(json['was_selected']),
      createdAt: json['created_at']?.toString(),
    );

  const Answer({
    required this.id,
    required this.questionId,
    required this.answerId,
    required this.answerText,
    this.answerTextVi,
    this.isCorrect,
    this.wasSelected,
    this.createdAt,
  });
  final String id; // ✅ Changed to String
  final String questionId; // ✅ Changed to String
  final String answerId;
  final String answerText;
  final String? answerTextVi;
  final bool? isCorrect;
  final bool? wasSelected;
  final String? createdAt;

  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  static bool? _parseBool(value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value == 1;
    }
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return null;
  }

  String getAnswerText({bool useVietnamese = false}) {
    if (useVietnamese && answerTextVi != null && answerTextVi!.isNotEmpty) {
      return answerTextVi!;
    }
    return answerText;
  }

  bool get hasVietnameseTranslation => answerTextVi != null && answerTextVi!.isNotEmpty;

  // ✅ Convenience getters for int values
  int get idInt => int.tryParse(id) ?? 0;
  int get questionIdInt => int.tryParse(questionId) ?? 0;

  // ✅ Helper properties
  bool get isCorrectAnswer => isCorrect == true;
  bool get wasSelectedByUser => wasSelected == true;

  // ✅ Create a copy with selection state
  Answer copyWithSelection(bool selected) => Answer(
      id: id,
      questionId: questionId,
      answerId: answerId,
      answerText: answerText,
      answerTextVi: answerTextVi,
      isCorrect: isCorrect,
      wasSelected: selected,
      createdAt: createdAt,
    );

  @override
  List<Object?> get props => [
    id,
    questionId,
    answerId,
    answerText,
    answerTextVi,
    isCorrect,
    wasSelected,
    createdAt,
  ];
}