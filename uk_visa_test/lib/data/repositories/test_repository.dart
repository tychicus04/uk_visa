import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Get available tests for current user
  Future<Map<String, List<Test>>> getAvailableTests({
    String? secondaryLanguage,
    @deprecated bool includeVietnamese = false,
  }) async {
    try {
      print('🌍 Repository: Loading tests with secondary language: $secondaryLanguage');

      final response = await _testService.getAvailableTests(
        secondaryLanguage: secondaryLanguage,
        includeVietnamese: includeVietnamese, // Backward compatibility
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        Map<String, dynamic> testsData;
        if (data.containsKey('tests')) {
          testsData = data['tests'] as Map<String, dynamic>;
        } else {
          testsData = data;
        }

        final result = <String, List<Test>>{};

        for (final testType in ['chapter', 'comprehensive', 'exam']) {
          final testList = testsData[testType];
          if (testList != null && testList is List) {
            try {
              final tests = testList.map((e) {
                return Test.fromJson(e as Map<String, dynamic>);
              }).toList();

              result[testType] = tests;
              print('✅ Repository: Parsed ${tests.length} $testType tests');
            } catch (e) {
              print('❌ Repository: Error parsing $testType tests: $e');
              result[testType] = <Test>[];
            }
          } else {
            result[testType] = <Test>[];
          }
        }

        final totalTests = result.values.fold<int>(0, (sum, list) => sum + list.length);
        print('🎯 Repository: Loaded $totalTests total tests with language: ${secondaryLanguage ?? 'none'}');

        return result;
      } else {
        throw Exception(response.message ?? 'Failed to load tests');
      }
    } catch (e) {
      print('💥 Repository error in getAvailableTests: $e');
      rethrow;
    }
  }

  /// Get free tests (no authentication required)
  Future<List<Test>> getFreeTests({
    String? secondaryLanguage,
    @deprecated bool includeVietnamese = false,
  }) async {
    try {
      final response = await _testService.getFreeTests(
          secondaryLanguage: secondaryLanguage,
          includeVietnamese: includeVietnamese
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

  /// Get specific test with questions
  Future<Test> getTest(
      int testId, {
        String? secondaryLanguage,
        @deprecated bool includeVietnamese = false,
        bool includeCorrectAnswers = false,
      }) async {
    try {
      final response = await _testService.getTest(
          testId,
          secondaryLanguage: secondaryLanguage,
          includeVietnamese: includeVietnamese,
          includeCorrectAnswers: includeCorrectAnswers);

      print('🔍 Repository received test response: ${response.success}');

      if (response.success && response.data != null) {
        final data = response.data!;
        print('📊 Raw test data keys: ${data.keys}');

        // ✅ Handle the correct API structure: data.test
        Map<String, dynamic> testData;

        if (data.containsKey('test')) {
          // New API structure: { data: { test: {...} } }
          testData = data['test'] as Map<String, dynamic>;
          print('✅ Using new API structure with test wrapper');
        } else {
          // Fallback: Direct structure { data: {...} }
          testData = data;
          print('⚠️ Using fallback direct structure');
        }

        print('📋 Test data keys: ${testData.keys}');
        print('📝 Test has ${(testData['questions'] as List?)?.length ?? 0} questions');

        final test = Test.fromJson(testData);

        // Debug the parsed test
        DebugHelper.debugTestObject(test);

        print('✅ Loaded test ${test.id}: ${test.displayTitle} with ${test.questions?.length ?? 0} questions');
        return test;
      } else {
        print('❌ API response failed: ${response.message}');
        throw Exception(response.message ?? 'Failed to load test');
      }
    } catch (e) {
      print('💥 Repository error in getTest($testId): $e');
      rethrow;
    }
  }

  /// Search tests
  Future<List<Test>> searchTests({
    String? secondaryLanguage,
    String? query,
    String? type,
    int? chapterId,
    @deprecated bool includeVietnamese = false,
  }) async {
    try {
      final response = await _testService.searchTests(
          secondaryLanguage: secondaryLanguage,
          query: query,
          type: type,
          chapterId: chapterId,
          includeVietnamese: includeVietnamese
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
      String type,
      {
        String? secondaryLanguage,
        @deprecated bool includeVietnamese = false,
      }) async {
    try {
      final response = await _testService.getTestsByType(
          type,
          secondaryLanguage: secondaryLanguage,
          includeVietnamese: includeVietnamese);

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
        @deprecated bool includeVietnamese = false,
      }) async {
    try {
      final response = await _testService.getTestsByChapter(
          chapterId,
          secondaryLanguage: secondaryLanguage,
          includeVietnamese: includeVietnamese);

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