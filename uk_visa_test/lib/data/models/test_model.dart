import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'question_model.dart';

part 'test_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Test extends Equatable {

  const Test({
    required this.id,
    this.chapterId,
    required this.testNumber,
    required this.testType,
    this.title,
    this.url,
    required this.isFree,
    required this.isPremium,
    required this.createdAt,
    this.chapterName,
    this.questionCount,
    this.canAccess,
    this.attemptCount,
    this.bestScore,
    this.questions,
    this.hasVietnameseTranslations,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 Parsing Test JSON: ${json['id']} - ${json['test_type']} - ${json['test_number']}');

      final test = Test(
        id: json['id']?.toString() ?? '0',
        chapterId: json['chapter_id']?.toString(),
        testNumber: json['test_number']?.toString() ?? '',
        testType: json['test_type']?.toString() ?? 'chapter',
        title: json['title']?.toString(),
        url: json['url']?.toString(),
        isFree: _parseBool(json['is_free']) ?? false,
        isPremium: _parseBool(json['is_premium']) ?? true,
        createdAt: json['created_at']?.toString() ?? '',
        chapterName: json['chapter_name']?.toString(),
        questionCount: json['question_count']?.toString(),
        // ✅ Handle missing can_access field - calculate based on is_free/is_premium
        canAccess: _calculateCanAccess(json),
        attemptCount: json['attempt_count']?.toString(),
        bestScore: _parseDouble(json['best_score']),
        questions: json['questions'] != null
            ? (json['questions'] as List).map((e) => Question.fromJson(e)).toList()
            : null,
        hasVietnameseTranslations: _parseBool(json['has_vietnamese_translations']),
      );

      print('✅ Successfully parsed test: ${test.id} - ${test.displayTitle}');
      return test;
    } catch (e, stackTrace) {
      print('❌ Error parsing test JSON: $e');
      print('📋 JSON data: $json');
      print('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  final String id;
  final String? chapterId;
  final String testNumber;
  final String testType;
  final String? title;
  final String? url;
  final bool isFree;
  final bool isPremium;
  final String createdAt;
  final String? chapterName;
  final String? questionCount;
  final bool? canAccess;
  final String? attemptCount;
  final double? bestScore;
  final List<Question>? questions;
  final bool? hasVietnameseTranslations;

  Map<String, dynamic> toJson() => _$TestToJson(this);

  // ✅ Helper function to safely parse boolean
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowercaseValue = value.toLowerCase();
      return lowercaseValue == 'true' || lowercaseValue == '1';
    }
    return null;
  }

  // ✅ Helper function to safely parse double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ✅ Calculate can_access based on available data
  static bool? _calculateCanAccess(Map<String, dynamic> json) {
    // If explicit can_access field exists, use it
    if (json.containsKey('can_access')) {
      return _parseBool(json['can_access']);
    }

    // Otherwise, calculate based on is_free
    // For now, assume all tests are accessible
    // In real app, this would depend on user's premium status
    final isFree = _parseBool(json['is_free']) ?? false;
    if (isFree) return true;

    // For premium tests, assume accessible for now
    // TODO: This should check user's premium status
    return true;
  }

  // ✅ Convenience getters for int values
  int get idInt => int.tryParse(id) ?? 0;
  int? get chapterIdInt => chapterId != null ? int.tryParse(chapterId!) : null;
  int get questionCountInt => int.tryParse(questionCount ?? '24') ?? 24;
  int get attemptCountInt => int.tryParse(attemptCount ?? '0') ?? 0;

  // ✅ Helper properties
  bool get isChapterTest => testType.toLowerCase() == 'chapter';
  bool get isComprehensiveTest => testType.toLowerCase() == 'comprehensive';
  bool get isExamTest => testType.toLowerCase() == 'exam';
  bool get isAccessible => canAccess == true;
  bool get hasAttempts => attemptCountInt > 0;
  bool get hasQuestions => questions != null && questions!.isNotEmpty;

  // ✅ Get display title with fallback
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }

    // Generate title based on test type and number
    switch (testType.toLowerCase()) {
      case 'chapter':
        return 'Chapter Test $testNumber';
      case 'comprehensive':
        return 'Comprehensive Test $testNumber';
      case 'exam':
        return 'Practice Exam $testNumber';
      default:
        return 'Test $testNumber';
    }
  }

  // ✅ Get test difficulty based on type and best score
  String get difficulty {
    if (bestScore == null) return 'Not attempted';
    if (bestScore! >= 90) return 'Mastered';
    if (bestScore! >= 75) return 'Good';
    if (bestScore! >= 50) return 'Needs practice';
    return 'Needs improvement';
  }

  // ✅ Check if user can access this test
  bool get isAvailable {
    // For now, return true for all tests
    // In production, this would check:
    // - Free tests: always available
    // - Premium tests: check user's subscription status
    return true;
  }

  // ✅ Get test type display name
  String get typeDisplayName {
    switch (testType.toLowerCase()) {
      case 'chapter':
        return 'Chapter';
      case 'comprehensive':
        return 'Mixed';
      case 'exam':
        return 'Exam';
      default:
        return testType;
    }
  }

  // ✅ Get chapter display name
  String get chapterDisplayName {
    if (chapterName != null) {
      // Remove "Chapter X: " prefix for cleaner display
      return chapterName!.replaceFirst(RegExp(r'^Chapter \d+:\s*'), '');
    }
    return 'Unknown Chapter';
  }

  // ✅ Check if this test has Vietnamese translations
  bool get supportsVietnamese => hasVietnameseTranslations == true;

  @override
  List<Object?> get props => [
    id,
    chapterId,
    testNumber,
    testType,
    title,
    url,
    isFree,
    isPremium,
    createdAt,
    chapterName,
    questionCount,
    canAccess,
    attemptCount,
    bestScore,
    questions,
    hasVietnameseTranslations,
  ];
}