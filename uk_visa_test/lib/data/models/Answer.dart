class Answer {
  final int id;
  final int questionId;
  final String answerId;
  final String answerText;
  final bool isCorrect;
  final bool? wasSelected;
  final DateTime createdAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.answerId,
    required this.answerText,
    required this.isCorrect,
    this.wasSelected,
    required this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      answerId: json['answer_id'] ?? '',
      answerText: json['answer_text'] ?? '',
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      wasSelected: json['was_selected'] == 1 || json['was_selected'] == true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'answer_id': answerId,
      'answer_text': answerText,
      'is_correct': isCorrect,
      'was_selected': wasSelected,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Answer copyWith({
    int? id,
    int? questionId,
    String? answerId,
    String? answerText,
    bool? isCorrect,
    bool? wasSelected,
    DateTime? createdAt,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answerId: answerId ?? this.answerId,
      answerText: answerText ?? this.answerText,
      isCorrect: isCorrect ?? this.isCorrect,
      wasSelected: wasSelected ?? this.wasSelected,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}