class AnswerSubmission {
  final int questionId;
  final List<String> selectedAnswerIds;

  AnswerSubmission({
    required this.questionId,
    required this.selectedAnswerIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_answer_ids': selectedAnswerIds,
    };
  }
}