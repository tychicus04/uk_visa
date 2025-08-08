// lib/data/models/test_model.dart - FIXED VERSION
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'question_model.dart';

part 'test_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Test extends Equatable {
  final String id; // ✅ Changed to String
  final String? chapterId; // ✅ Changed to String
  final String testNumber;
  final String testType;
  final String? title;
  final String? url;
  final bool isFree;
  final bool isPremium;
  final String createdAt;
  final String? chapterName;
  final String? questionCount; // ✅ Changed to String
  final bool? canAccess;
  final String? attemptCount; // ✅ Changed to String
  final double? bestScore;
  final List<Question>? questions;

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
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    // ✅ Safe type conversion with null safety
    return Test(
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
      canAccess: _parseBool(json['can_access']),
      attemptCount: json['attempt_count']?.toString(),
      bestScore: _parseDouble(json['best_score']),
      questions: json['questions'] != null
          ? (json['questions'] as List).map((e) => Question.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$TestToJson(this);

  // ✅ Helper function to safely parse boolean
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
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

  // ✅ Get display title
  String get displayTitle => title ?? 'Test $testNumber';

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
    if (isFree) return true;
    return canAccess == true;
  }

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
  ];
}