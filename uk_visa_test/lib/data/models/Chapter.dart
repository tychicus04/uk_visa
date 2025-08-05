import 'dart:convert';

class Chapter {
  final int id;
  final int chapterNumber;
  final String name;
  final String? description;
  final int totalTests;
  final int freeTests;
  final int premiumTests;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.name,
    this.description,
    required this.totalTests,
    required this.freeTests,
    required this.premiumTests,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? 0,
      chapterNumber: json['chapter_number'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      totalTests: json['total_tests'] ?? 0,
      freeTests: json['free_tests'] ?? 0,
      premiumTests: json['premium_tests'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'name': name,
      'description': description,
      'total_tests': totalTests,
      'free_tests': freeTests,
      'premium_tests': premiumTests,
      'created_at': createdAt.toIso8601String(),
    };
  }
}