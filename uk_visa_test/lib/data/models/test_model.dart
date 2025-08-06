// lib/data/models/test_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_model.g.dart';

// lib/data/models/test_model.dart - Fixed version
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Test extends Equatable {
  final int id;
  final int? chapterId;
  final String testNumber;
  final String testType;
  final String? title;
  final String? url;
  final bool isFree;
  final bool isPremium;
  final String createdAt;
  final String? chapterName;
  final int? questionCount;
  final bool? canAccess;
  final int? attemptCount;
  final double? bestScore;

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
  });

  factory Test.fromJson(Map<String, dynamic> json) => _$TestFromJson(json);
  Map<String, dynamic> toJson() => _$TestToJson(this);

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
  ];
}

