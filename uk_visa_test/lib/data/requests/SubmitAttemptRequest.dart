import '../models/AnswerSubmission.dart';

class SubmitAttemptRequest {
  final int attemptId;
  final int? timeTaken;
  final List<AnswerSubmission> answers;

  SubmitAttemptRequest({
    required this.attemptId,
    this.timeTaken,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'time_taken': timeTaken,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}