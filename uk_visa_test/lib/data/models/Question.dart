import 'Answer.dart';

class Question {
  final int id;
  final int testId;
  final String questionId;
  final String questionText;
  final String questionType;
  final String? explanation;
  final List<Answer> answers;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.testId,
    required this.questionId,
    required this.questionText,
    required this.questionType,
    this.explanation,
    this.answers = const [],
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      testId: json['test_id'] ?? 0,
      questionId: json['question_id'] ?? '',
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'radio',
      explanation: json['explanation'],
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => Answer.fromJson(a)).toList()
          : [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      'question_id': questionId,
      'question_text': questionText,
      'question_type': questionType,
      'explanation': explanation,
      'answers': answers.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isRadio => questionType == 'radio';
  bool get isCheckbox => questionType == 'checkbox';
  List<Answer> get correctAnswers => answers.where((a) => a.isCorrect).toList();
  bool get hasExplanation => explanation != null && explanation!.isNotEmpty;
}