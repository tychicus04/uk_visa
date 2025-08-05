class SubscribeRequest {
  final String planId;
  final String paymentMethod;
  final String paymentToken;

  SubscribeRequest({
    required this.planId,
    required this.paymentMethod,
    required this.paymentToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'payment_method': paymentMethod,
      'payment_token': paymentToken,
    };
  }
}