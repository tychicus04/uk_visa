class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String languageCode;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.languageCode = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'language_code': languageCode,
    };
  }
}