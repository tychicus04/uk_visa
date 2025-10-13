import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_helper.dart';
import '../../core/utils/debug_helper.dart';
import '../models/test_model.dart';
import '../services/test_service.dart';

final testRepositoryProvider = Provider<TestRepository>((ref) {
  final testService = ref.watch(testServiceProvider);
  return TestRepository(testService);
});

class TestRepository {
  TestRepository(this._testService);
  final TestService _testService;

  /// Get available tests for current user (using offline database)
  Future<Map<String, List<Test>>> getAvailableTests({
    String? secondaryLanguage,
  }) async {
    try {
      print('🗄️ Repository: Loading tests from offline database');
      print('🌍 Repository: Secondary language: $secondaryLanguage');

      // Get all tests from database
      final allTests = await DatabaseHelper.instance.getAllTests();

      final result = <String, List<Test>>{
        'chapter': <Test>[],
        'comprehensive': <Test>[],
        'exam': <Test>[],
      };

      // Parse and categorize tests
      for (final testData in allTests) {
        try {
          final test = Test.fromJson(testData);
          final testType = test.testType.toLowerCase();
          
          if (result.containsKey(testType)) {
            result[testType]!.add(test);
            print('🔧 Parsing Test JSON: ${test.id} - ${test.testType} - ${test.testNumber}');
            print('✅ Successfully parsed test: ${test.id} - ${test.displayTitle}');
          }
        } catch (e) {
          print('❌ Repository: Error parsing test: $e');
        }
      }

      // Log results
      for (final entry in result.entries) {
        print('✅ Repository: Parsed ${entry.value.length} ${entry.key} tests');
      }

      final totalTests = result.values.fold<int>(0, (sum, list) => sum + list.length);
      print('🎯 Total: $totalTests tests across ${result.keys.length} categories with language: $secondaryLanguage');
      
      return result;
    } catch (e) {
      print('💥 Repository error in getAvailableTests: $e');
      rethrow;
    }
  }

  /// Get free tests (no authentication required)
  Future<List<Test>> getFreeTests({
    String? secondaryLanguage,
  }) async {
    try {
      final response = await _testService.getFreeTests(
          secondaryLanguage: secondaryLanguage
      );

      if (response.success && response.data != null) {
        final tests = (response.data!).map((e) => Test.fromJson(e)).toList();
        print('✅ Loaded ${tests.length} free tests');
        return tests;
      } else {
        throw Exception(response.message ?? 'Failed to load free tests');
      }
    } catch (e) {
      print('💥 Repository error in getFreeTests: $e');
      rethrow;
    }
  }

  /// Get specific test with questions (using offline database)
  Future<Test> getTest(
      int testId, {
        String? secondaryLanguage,
        bool includeCorrectAnswers = false,
      }) async {
    try {
      print('📄 Loading test detail for: $testId from database');

      // Get test data from local database
      final testData = await DatabaseHelper.instance.getCompleteTestData(testId);
      
      if (testData == null) {
        throw Exception('Test $testId not found in database');
      }

      print('📊 Raw test data keys: ${testData.keys}');

      // The database returns a structure like { test: {...}, questions: [...] }
      final testJson = testData['test'] as Map<String, dynamic>;
      final questionsJson = testData['questions'] as List<dynamic>;
      
      // Add questions to the test JSON so fromJson can parse them
      testJson['questions'] = questionsJson;
      
      final test = Test.fromJson(testJson);

      print('✅ Loaded test ${test.id}: ${test.displayTitle} with ${test.questions?.length ?? 0} questions from database');
      return test;
    } catch (e) {
      print('💥 Repository error in getTest($testId): $e');
      rethrow;
    }
  }

  /// Search tests
  Future<List<Test>> searchTests(
      String query, {
        String? secondaryLanguage,
        String? type,
        int? chapterId,
      }) async {
    try {
      final response = await _testService.searchTests(
          secondaryLanguage: secondaryLanguage,
          query: query,
          type: type,
          chapterId: chapterId
      );

      if (response.success && response.data != null) {
        final tests = (response.data!).map((e) => Test.fromJson(e)).toList();
        print('✅ Found ${tests.length} tests for query: "$query"');
        return tests;
      } else {
        throw Exception(response.message ?? 'Failed to search tests');
      }
    } catch (e) {
      print('💥 Repository error in searchTests: $e');
      rethrow;
    }
  }

  /// Get tests by type
  Future<List<Test>> getTestsByType(
      String type, {
        String? secondaryLanguage,
      }) async {
    try {
      final response = await _testService.getTestsByType(
          type,
          secondaryLanguage: secondaryLanguage);

      if (response.success && response.data != null) {
        final tests = (response.data!).map((e) => Test.fromJson(e)).toList();
        print('✅ Loaded ${tests.length} tests of type: $type');
        return tests;
      } else {
        throw Exception(response.message ?? 'Failed to load tests by type');
      }
    } catch (e) {
      print('💥 Repository error in getTestsByType($type): $e');
      rethrow;
    }
  }

  /// Get tests by chapter
  Future<List<Test>> getTestsByChapter(
      int chapterId, {
        String? secondaryLanguage,
      }) async {
    try {
      final response = await _testService.getTestsByChapter(
          chapterId,
          secondaryLanguage: secondaryLanguage);

      if (response.success && response.data != null) {
        final tests = (response.data!).map((e) => Test.fromJson(e)).toList();
        print('✅ Loaded ${tests.length} tests for chapter: $chapterId');
        return tests;
      } else {
        throw Exception(response.message ?? 'Failed to load chapter tests');
      }
    } catch (e) {
      print('💥 Repository error in getTestsByChapter($chapterId): $e');
      rethrow;
    }
  }
}