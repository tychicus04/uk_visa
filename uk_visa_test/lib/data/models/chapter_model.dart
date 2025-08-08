// lib/data/models/chapter_model.dart - FIXED VERSION
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'test_model.dart';

part 'chapter_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Chapter extends Equatable {
  final String id; // ✅ Changed to String
  final String chapterNumber; // ✅ Changed to String
  final String name;
  final String? description;
  final String? totalTests; // ✅ Changed to String
  final String? freeTests; // ✅ Changed to String
  final String? premiumTests; // ✅ Changed to String
  final List<Test>? tests;
  final String createdAt;

  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.name,
    this.description,
    this.totalTests,
    this.freeTests,
    this.premiumTests,
    this.tests,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    // ✅ Safe type conversion with null safety
    return Chapter(
      id: json['id']?.toString() ?? '0',
      chapterNumber: json['chapter_number']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      totalTests: json['total_tests']?.toString(),
      freeTests: json['free_tests']?.toString(),
      premiumTests: json['premium_tests']?.toString(),
      tests: json['tests'] != null
          ? (json['tests'] as List).map((e) => Test.fromJson(e)).toList()
          : null,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$ChapterToJson(this);

  // ✅ Convenience getters for int values
  int get idInt => int.tryParse(id) ?? 0;
  int get chapterNumberInt => int.tryParse(chapterNumber) ?? 0;
  int get totalTestsInt => int.tryParse(totalTests ?? '0') ?? 0;
  int get freeTestsInt => int.tryParse(freeTests ?? '0') ?? 0;
  int get premiumTestsInt => int.tryParse(premiumTests ?? '0') ?? 0;

  // ✅ Helper properties
  bool get hasTests => tests != null && tests!.isNotEmpty;
  bool get hasFreeTests => freeTestsInt > 0;
  bool get hasPremiumTests => premiumTestsInt > 0;

  // ✅ Get chapter display name
  String get displayName => 'Chapter $chapterNumber: ${name.replaceFirst('Chapter $chapterNumber: ', '')}';

  // ✅ Get short chapter name (without chapter number prefix)
  String get shortName => name.replaceFirst(RegExp(r'^Chapter \d+:\s*'), '');

  // ✅ Get completion progress (if tests have attempt data)
  double get completionProgress {
    if (!hasTests) return 0.0;

    final testsWithAttempts = tests!.where((test) => test.hasAttempts).length;
    return testsWithAttempts / tests!.length;
  }

  // ✅ Get average score across all tests
  double? get averageScore {
    if (!hasTests) return null;

    final testsWithScores = tests!.where((test) => test.bestScore != null).toList();
    if (testsWithScores.isEmpty) return null;

    final totalScore = testsWithScores.fold<double>(0, (sum, test) => sum + (test.bestScore ?? 0));
    return totalScore / testsWithScores.length;
  }

  // ✅ Get available tests for user
  List<Test> get availableTests {
    if (!hasTests) return [];
    return tests!.where((test) => test.isAvailable).toList();
  }

  // ✅ Get tests by type
  List<Test> getTestsByType(String type) {
    if (!hasTests) return [];
    return tests!.where((test) => test.testType == type).toList();
  }

  @override
  List<Object?> get props => [
    id,
    chapterNumber,
    name,
    description,
    totalTests,
    freeTests,
    premiumTests,
    tests,
    createdAt,
  ];
}