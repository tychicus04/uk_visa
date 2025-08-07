import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/test_service.dart';
import '../models/test_model.dart';

final testRepositoryProvider = Provider<TestRepository>((ref) {
  final testService = ref.watch(testServiceProvider);
  return TestRepository(testService);
});

class TestRepository {
  final TestService _testService;

  TestRepository(this._testService);

  /// Get available tests for current user
  Future<Map<String, List<Test>>> getAvailableTests() async {
    final response = await _testService.getAvailableTests();

    if (response.success && response.data != null) {
      final data = response.data!;
      return {
        'chapter': data['chapter'] != null
            ? (data['chapter'] as List).map((e) => Test.fromJson(e)).toList()
            : <Test>[],
        'comprehensive': data['comprehensive'] != null
            ? (data['comprehensive'] as List).map((e) => Test.fromJson(e)).toList()
            : <Test>[],
        'exam': data['exam'] != null
            ? (data['exam'] as List).map((e) => Test.fromJson(e)).toList()
            : <Test>[],
      };
    } else {
      throw Exception(response.message ?? 'Failed to load tests');
    }
  }

  /// Get free tests (no authentication required)
  Future<List<Test>> getFreeTests() async {
    final response = await _testService.getFreeTests();

    if (response.success && response.data != null) {
      return (response.data! as List).map((e) => Test.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load free tests');
    }
  }

  /// Get specific test with questions
  Future<Test> getTest(int testId) async {
    final response = await _testService.getTest(testId);

    if (response.success && response.data != null) {
      return Test.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to load test');
    }
  }

  /// Search tests
  Future<List<Test>> searchTests({
    String? query,
    String? type,
    int? chapterId,
  }) async {
    final response = await _testService.searchTests(
      query: query,
      type: type,
      chapterId: chapterId,
    );

    if (response.success && response.data != null) {
      return (response.data! as List).map((e) => Test.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to search tests');
    }
  }

  /// Get tests by type
  Future<List<Test>> getTestsByType(String type) async {
    final response = await _testService.getTestsByType(type);

    if (response.success && response.data != null) {
      return (response.data! as List).map((e) => Test.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load tests by type');
    }
  }

  /// Get tests by chapter
  Future<List<Test>> getTestsByChapter(int chapterId) async {
    final response = await _testService.getTestsByChapter(chapterId);

    if (response.success && response.data != null) {
      return (response.data! as List).map((e) => Test.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load chapter tests');
    }
  }
}
