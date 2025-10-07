import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id; 
  final String username;
  final String? email;
  final String? fullName;
  final bool isPremium;
  final String? premiumExpiresAt;
  final String languageCode;
  final String freeTestsUsed;
  final String freeTestsLimit;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.username,
    this.email,
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
    return User(
      id: json['id']?.toString() ?? '0',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'is_premium': isPremium,
    'premium_expires_at': premiumExpiresAt,
    'language_code': languageCode,
    'free_tests_used': freeTestsUsed,
    'free_tests_limit': freeTestsLimit,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  int get freeTestsUsedInt => int.tryParse(freeTestsUsed) ?? 0;
  int get freeTestsLimitInt => int.tryParse(freeTestsLimit) ?? 5;
  int get userIdInt => int.tryParse(id) ?? 0;

  bool get hasRemainingFreeTests => freeTestsUsedInt < freeTestsLimitInt;

  @override
  List<Object?> get props => [
    id,
    username,
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