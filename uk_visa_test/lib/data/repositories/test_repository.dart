import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_helper.dart';
import '../models/test_model.dart';

final testRepositoryProvider = Provider<TestRepository>((ref) {
  return TestRepository();
});

class TestRepository {
  TestRepository();

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

  /// Get free tests (offline - returns all tests from database)
  Future<List<Test>> getFreeTests({
    String? secondaryLanguage,
  }) async {
    try {
      print('🗄️ Repository: Loading free tests from offline database');
      
      // Get all tests from database (offline mode - all tests are free)
      final allTests = await DatabaseHelper.instance.getAllTests();
      final tests = allTests.map((testData) => Test.fromJson(testData)).toList();
      
      print('✅ Loaded ${tests.length} free tests from database');
      return tests;
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

  /// Search tests (offline - search in local database)
  Future<List<Test>> searchTests(
      String query, {
        String? secondaryLanguage,
        String? type,
        int? chapterId,
      }) async {
    try {
      print('🗄️ Repository: Searching tests in offline database');
      
      // Get all tests from database
      final allTests = await DatabaseHelper.instance.getAllTests();
      var tests = allTests.map((testData) => Test.fromJson(testData)).toList();
      
      // Filter by query (search in title)
      if (query.isNotEmpty) {
        tests = tests.where((test) {
          final titleLower = (test.title ?? '').toLowerCase();
          final queryLower = query.toLowerCase();
          return titleLower.contains(queryLower);
        }).toList();
      }
      
      // Filter by type if provided
      if (type != null && type.isNotEmpty) {
        tests = tests.where((test) => test.testType.toLowerCase() == type.toLowerCase()).toList();
      }
      
      // Filter by chapter if provided
      if (chapterId != null) {
        tests = tests.where((test) => test.chapterIdInt == chapterId).toList();
      }
      
      print('✅ Found ${tests.length} tests for query: "$query"');
      return tests;
    } catch (e) {
      print('💥 Repository error in searchTests: $e');
      rethrow;
    }
  }

  /// Get tests by type (offline - filter from local database)
  Future<List<Test>> getTestsByType(
      String type, {
        String? secondaryLanguage,
      }) async {
    try {
      print('🗄️ Repository: Loading tests by type from offline database');
      
      // Get all tests from database
      final allTests = await DatabaseHelper.instance.getAllTests();
      final tests = allTests
          .map((testData) => Test.fromJson(testData))
          .where((test) => test.testType.toLowerCase() == type.toLowerCase())
          .toList();
      
      print('✅ Loaded ${tests.length} tests of type: $type');
      return tests;
    } catch (e) {
      print('💥 Repository error in getTestsByType($type): $e');
      rethrow;
    }
  }

  /// Get tests by chapter (offline - filter from local database)
  Future<List<Test>> getTestsByChapter(
      int chapterId, {
        String? secondaryLanguage,
      }) async {
    try {
      print('🗄️ Repository: Loading tests by chapter from offline database');
      
      // Get all tests from database
      final allTests = await DatabaseHelper.instance.getAllTests();
      final tests = allTests
          .map((testData) => Test.fromJson(testData))
          .where((test) => test.chapterIdInt == chapterId)
          .toList();
      
      print('✅ Loaded ${tests.length} tests for chapter: $chapterId');
      return tests;
    } catch (e) {
      print('💥 Repository error in getTestsByChapter($chapterId): $e');
      rethrow;
    }
  }
}