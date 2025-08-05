import 'dart:convert';

import 'package:uk_visa_test/data/models/UserStats.dart';

class User {
  final int id;
  final String email;
  final String? fullName;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final String languageCode;
  final int freeTestsUsed;
  final int freeTestsLimit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStats? stats;

  User({
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
    this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'],
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'])
          : null,
      languageCode: json['language_code'] ?? 'en',
      freeTestsUsed: json['free_tests_used'] ?? 0,
      freeTestsLimit: json['free_tests_limit'] ?? 5,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'language_code': languageCode,
      'free_tests_used': freeTestsUsed,
      'free_tests_limit': freeTestsLimit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'stats': stats?.toJson(),
    };
  }

  String toJsonString() => json.encode(toJson());

  factory User.fromJsonString(String jsonString) => User.fromJson(json.decode(jsonString));

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    String? languageCode,
    int? freeTestsUsed,
    int? freeTestsLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      languageCode: languageCode ?? this.languageCode,
      freeTestsUsed: freeTestsUsed ?? this.freeTestsUsed,
      freeTestsLimit: freeTestsLimit ?? this.freeTestsLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  // Computed properties
  bool get canTakeFreeTest => freeTestsUsed < freeTestsLimit;
  int get remainingFreeTests => freeTestsLimit - freeTestsUsed;
  bool get isPremiumExpired =>
      premiumExpiresAt != null && premiumExpiresAt!.isBefore(DateTime.now());
  bool get hasActiveSubscription => isPremium && !isPremiumExpired;

  @override
  String toString() {
    return 'User(id: $id, email: $email, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}