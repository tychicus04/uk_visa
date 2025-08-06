// lib/data/models/chapter_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uk_visa_test/data/models/test_model.dart';

part 'chapter_model.g.dart';

// lib/data/models/chapter_model.dart - Fixed version
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Chapter extends Equatable {
  final int id;
  final int chapterNumber;
  final String name;
  final String? description;
  final int? totalTests;
  final int? freeTests;
  final int? premiumTests;
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

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterToJson(this);

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


