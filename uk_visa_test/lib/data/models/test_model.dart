import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'question_model.dart';

part 'test_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Test extends Equatable {

  const Test({
    required this.id,
    required this.testNumber,
    required this.testType,
    required this.isFree,
    required this.isPremium,
    required this.createdAt,
    this.chapterId,
    this.title,
    this.url,
    this.chapterName,
    this.questionCount,
    this.canAccess,
    this.attemptCount,
    this.bestScore,
    this.questions,
    this.hasVietnameseTranslations,
    this.timeLimitMinutes, // NEW: Time limit for exam mode
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
        canAccess: _calculateCanAccess(json),
        attemptCount: json['attempt_count']?.toString(),
        bestScore: _parseDouble(json['best_score']),
        questions: json['questions'] != null
            ? (json['questions'] as List).map((e) => Question.fromJson(e)).toList()
            : null,
        hasVietnameseTranslations: _parseBool(json['has_vietnamese_translations']),
        timeLimitMinutes: _parseInt(json['time_limit_minutes']), // NEW: Parse time limit
      );

      print('✅ Successfully parsed test: ${test.id} - ${test.displayTitle}');
      return test;
    } catch (e, stackTrace) {
      print('⚠ Error parsing test JSON: $e');
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
  final int? timeLimitMinutes; // NEW: Time limit in minutes

  Map<String, dynamic> toJson() => _$TestToJson(this);

  // Helper functions
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

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // NEW: Helper to parse int values
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _calculateCanAccess(Map<String, dynamic> json) {
    if (json.containsKey('can_access')) {
      return _parseBool(json['can_access']);
    }
    final isFree = _parseBool(json['is_free']) ?? false;
    if (isFree) return true;
    return true;
  }

  // Convenience getters
  int get idInt => int.tryParse(id) ?? 0;
  int? get chapterIdInt => chapterId != null ? int.tryParse(chapterId!) : null;
  int get questionCountInt => int.tryParse(questionCount ?? '24') ?? 24;
  int get attemptCountInt => int.tryParse(attemptCount ?? '0') ?? 0;

  // NEW: Get time limit as Duration for exam mode
  Duration? get timeLimit => timeLimitMinutes != null
      ? Duration(minutes: timeLimitMinutes!)
      : null;

  // NEW: Get default time limit based on test type
  Duration get defaultTimeLimit {
    switch (testType.toLowerCase()) {
      case 'exam':
        return const Duration(minutes: 45); // Official exam time
      case 'comprehensive':
        return const Duration(minutes: 30); // Comprehensive test
      case 'chapter':
        return const Duration(minutes: 20); // Chapter test
      default:
        return const Duration(minutes: 45);
    }
  }

  // NEW: Get effective time limit (from DB or default)
  Duration get effectiveTimeLimit => timeLimit ?? defaultTimeLimit;

  // Helper properties
  bool get isChapterTest => testType.toLowerCase() == 'chapter';
  bool get isComprehensiveTest => testType.toLowerCase() == 'comprehensive';
  bool get isExamTest => testType.toLowerCase() == 'exam';
  bool get isTimed => isExamTest || isComprehensiveTest;
  bool get isAccessible => canAccess == true;
  bool get hasAttempts => attemptCountInt > 0;
  bool get hasQuestions => questions != null && questions!.isNotEmpty;

  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }

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

  String get difficulty {
    if (bestScore == null) return 'Not attempted';
    if (bestScore! >= 90) return 'Mastered';
    if (bestScore! >= 75) return 'Good';
    if (bestScore! >= 50) return 'Needs practice';
    return 'Needs improvement';
  }

  bool get isAvailable => true;

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

  String get chapterDisplayName {
    if (chapterName != null) {
      return chapterName!.replaceFirst(RegExp(r'^Chapter \d+:\s*'), '');
    }
    return 'Unknown Chapter';
  }

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
    timeLimitMinutes,
  ];
}