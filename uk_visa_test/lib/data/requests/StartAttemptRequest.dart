// Request Models
class StartAttemptRequest {
  final int testId;

  StartAttemptRequest({required this.testId});

  Map<String, dynamic> toJson() => {'test_id': testId};
}