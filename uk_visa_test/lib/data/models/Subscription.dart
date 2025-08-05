class Subscription {
  final int id;
  final String subscriptionType;
  final double amount;
  final String currency;
  final String status;
  final DateTime startsAt;
  final DateTime? expiresAt;

  Subscription({
    required this.id,
    required this.subscriptionType,
    required this.amount,
    required this.currency,
    required this.status,
    required this.startsAt,
    this.expiresAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      subscriptionType: json['subscription_type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? '',
      startsAt: DateTime.parse(json['starts_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
}