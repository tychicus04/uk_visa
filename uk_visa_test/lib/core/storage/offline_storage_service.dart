import 'package:hive/hive.dart';

import '../../data/models/test_model.dart';

class OfflineStorageService {
  static const String _testsBox = 'offline_tests';
  static const String _progressBox = 'user_progress';
  static const String _answersBox = 'test_answers';

  static late Box _tests;
  static late Box _progress;
  static late Box _answers;

  static Future<void> init() async {
    await Hive.openBox(_testsBox);
    await Hive.openBox(_progressBox);
    await Hive.openBox(_answersBox);

    _tests = Hive.box(_testsBox);
    _progress = Hive.box(_progressBox);
    _answers = Hive.box(_answersBox);
  }

  // Cache test data for offline use
  static Future<void> cacheTest(Test test) async {
    await _tests.put(test.id, test.toJson());
  }

  static Test? getCachedTest(String testId) {
    final data = _tests.get(testId);
    return data != null ? Test.fromJson(Map<String, dynamic>.from(data)) : null;
  }

  // Store test answers locally
  static Future<void> storeTestAnswers({
    required String attemptId,
    required Map<String, List<String>> answers,
    required DateTime timestamp,
  }) async {
    await _answers.put(attemptId, {
      'answers': answers,
      'timestamp': timestamp.toIso8601String(),
      'synced': false,
    });
  }

  // Get unsynced answers for upload when online
  static List<Map<String, dynamic>> getUnsyncedAnswers() => _answers.values
        .where((data) => data['synced'] == false)
        .map((data) => Map<String, dynamic>.from(data))
        .toList();

  // Mark answers as synced
  static Future<void> markAnswersSynced(String attemptId) async {
    final data = _answers.get(attemptId);
    if (data != null) {
      data['synced'] = true;
      await _answers.put(attemptId, data);
    }
  }

  // Store user progress
  static Future<void> storeProgress({
    required String userId,
    required Map<String, dynamic> progressData,
  }) async {
    await _progress.put(userId, progressData);
  }

  static Map<String, dynamic>? getUserProgress(String userId) {
    final data = _progress.get(userId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }
}