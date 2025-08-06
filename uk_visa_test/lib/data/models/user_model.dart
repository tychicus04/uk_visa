// lib/data/models/user_model.dart - Fixed version
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class User extends Equatable {
  final int id;
  final String email;
  final String? fullName;
  final bool isPremium;
  final String? premiumExpiresAt;
  final String languageCode;
  final int freeTestsUsed;
  final int freeTestsLimit;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.isPremium,
    this.premiumExpiresAt,
    required this.languageCode,
    required this.freeTestsUsed,
    required this.freeTestsLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    isPremium,
    premiumExpiresAt,
    languageCode,
    freeTestsUsed,
    freeTestsLimit,
    createdAt,
    updatedAt,
  ];
}


