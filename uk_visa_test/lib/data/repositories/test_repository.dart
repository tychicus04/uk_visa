import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/test_model.dart';
import '../services/test_service.dart';
import '../../core/utils/debug_helper.dart';

final testRepositoryProvider = Provider<TestRepository>((ref) {
  final testService = ref.watch(testServiceProvider);
  return TestRepository(testService);
});

class TestRepository {
  TestRepository(this._testService);
  final TestService _testService;

  /// Get available tests for current user
  Future<Map<String, List<Test>>> getAvailableTests({
    bool includeVietnamese = false,
  }) async {
    try {
      final response = await _testService.getAvailableTests(
        includeVietnamese: includeVietnamese,
      );

      print('🔍 Repository received response: ${response.success}');

      if (response.success && response.data != null) {
        final data = response.data!;
        print('📊 Raw data keys: ${data.keys}');

        // ✅ Handle the correct API structure: data.tests.{type}
        Map<String, dynamic> testsData;

        if (data.containsKey('tests')) {
          // New API structure: { data: { tests: { chapter: [...], comprehensive: [...] } } }
          testsData = data['tests'] as Map<String, dynamic>;
          print('✅ Using new API structure with tests wrapper');
        } else {
          // Fallback: Direct structure { data: { chapter: [...], comprehensive: [...] } }
          testsData = data;
          print('⚠️ Using fallback direct structure');
        }

        print('📋 Tests data keys: ${testsData.keys}');

        final result = <String, List<Test>>{};

        // Process each test type
        for (final testType in ['chapter', 'comprehensive', 'exam']) {
          final testList = testsData[testType];

          if (testList != null && testList is List) {
            try {
              final tests = testList.map((e) {
                print('🔧 Parsing test: ${e['id']} - ${e['test_type']} - ${e['test_number']}');
                return Test.fromJson(e as Map<String, dynamic>);
              }).toList();

              result[testType] = tests;
              print('✅ Parsed ${tests.length} $testType tests');
            } catch (e) {
              print('❌ Error parsing $testType tests: $e');
              result[testType] = <Test>[];
            }
          } else {
            print('⚠️ No $testType tests found or invalid format');
            result[testType] = <Test>[];
          }
        }

        final totalTests = result.values.fold<int>(0, (sum, list) => sum + list.length);
        print('🎯 Final result: $totalTests total tests across ${result.keys.length} types');

        return result;
      } else {
        print('❌ API response failed: ${response.message}');
        throw Exception(response.message ?? 'Failed to load tests');
      }
    } catch (e) {
      print('💥 Repository error in getAvailableTests: $e');
      rethrow;
    }
  }

  /// Get free tests (no authentication required)
  Future<List<Test>> getFreeTests({
    bool includeVietnamese = false,
  }) async {
    try {
      final response = await _testService.getFreeTests(
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
        bool includeVietnamese = false,
        bool includeCorrectAnswers = false,
      }) async {
    try {
      final response = await _testService.getTest(
          testId,
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
    String? query,
    String? type,
    int? chapterId,
    bool includeVietnamese = false,
  }) async {
    try {
      final response = await _testService.searchTests(
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
      String type, {
        bool includeVietnamese = false,
      }) async {
    try {
      final response = await _testService.getTestsByType(
          type,
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
        bool includeVietnamese = false,
      }) async {
    try {
      final response = await _testService.getTestsByChapter(
          chapterId,
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