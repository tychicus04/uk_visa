// lib/data/models/user_model.dart - FIXED VERSION
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class User extends Equatable {
  final String id; // ✅ Changed to String for consistency
  final String email;
  final String? fullName;
  final bool isPremium;
  final String? premiumExpiresAt;
  final String languageCode;
  final String freeTestsUsed; // ✅ Changed to String
  final String freeTestsLimit; // ✅ Changed to String
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

  factory User.fromJson(Map<String, dynamic> json) {
    // ✅ Add null safety and type conversion
    return User(
      id: json['id']?.toString() ?? '0',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      isPremium: _parseBool(json['is_premium']),
      premiumExpiresAt: json['premium_expires_at']?.toString(),
      languageCode: json['language_code']?.toString() ?? 'en',
      freeTestsUsed: json['free_tests_used']?.toString() ?? '0',
      freeTestsLimit: json['free_tests_limit']?.toString() ?? '5',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // ✅ Helper function to safely parse boolean
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // ✅ Convenience getters for int values
  int get freeTestsUsedInt => int.tryParse(freeTestsUsed) ?? 0;
  int get freeTestsLimitInt => int.tryParse(freeTestsLimit) ?? 5;
  int get userIdInt => int.tryParse(id) ?? 0;

  // ✅ Helper to check if user has remaining free tests
  bool get hasRemainingFreeTests => freeTestsUsedInt < freeTestsLimitInt;

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