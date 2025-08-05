import 'dart:convert';

import 'Question.dart';

class Test {
  final int id;
  final int? chapterId;
  final String testNumber;
  final String testType;
  final String title;
  final String? url;
  final bool isFree;
  final bool isPremium;
  final bool canAccess;
  final int attemptCount;
  final double? bestScore;
  final String? chapterName;
  final int questionCount;
  final List<Question> questions;
  final DateTime createdAt;

  Test({
    required this.id,
    this.chapterId,
    required this.testNumber,
    required this.testType,
    required this.title,
    this.url,
    required this.isFree,
    required this.isPremium,
    required this.canAccess,
    required this.attemptCount,
    this.bestScore,
    this.chapterName,
    required this.questionCount,
    this.questions = const [],
    required this.createdAt,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'] ?? 0,
      chapterId: json['chapter_id'],
      testNumber: json['test_number'] ?? '',
      testType: json['test_type'] ?? '',
      title: json['title'] ?? '',
      url: json['url'],
      isFree: json['is_free'] == 1 || json['is_free'] == true,
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
      canAccess: json['can_access'] == 1 || json['can_access'] == true,
      attemptCount: json['attempt_count'] ?? 0,
      bestScore: json['best_score']?.toDouble(),
      chapterName: json['chapter_name'],
      questionCount: json['question_count'] ?? 0,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'test_number': testNumber,
      'test_type': testType,
      'title': title,
      'url': url,
      'is_free': isFree,
      'is_premium': isPremium,
      'can_access': canAccess,
      'attempt_count': attemptCount,
      'best_score': bestScore,
      'chapter_name': chapterName,
      'question_count': questionCount,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isChapterTest => testType == 'chapter';
  bool get isComprehensiveTest => testType == 'comprehensive';
  bool get isExamTest => testType == 'exam';
  bool get hasAttempts => attemptCount > 0;
  bool get isPassed => bestScore != null && bestScore! >= 75.0;
  String get formattedBestScore => bestScore != null ? '${bestScore!.toStringAsFixed(1)}%' : '-';
}