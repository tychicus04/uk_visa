class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final int? duration;
  final String? discount;
  final bool popular;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    this.duration,
    this.discount,
    this.popular = false,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      duration: json['duration'],
      discount: json['discount'],
      popular: json['popular'] ?? false,
      features: (json['features'] as List? ?? []).cast<String>(),
    );
  }
}