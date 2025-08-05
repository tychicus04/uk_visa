// App Constants
class AppConstants {
  // App Info
  static const String appName = 'UK Visa Test';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Life in the UK Practice Test';

  // API Configuration
  static const String baseUrl = 'http://localhost/UKVisa/backend';
  static const String apiUrl = '$baseUrl/api';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_completed';

  // Test Configuration
  static const int freeTestLimit = 5;
  static const double passingScore = 75.0;
  static const int questionsPerTest = 24;
  static const Duration testTimeLimit = Duration(minutes: 45);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double cardElevation = 4.0;
  static const double extraLargePadding = 32.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Subscription Plans
  static const String monthlyPlanId = 'monthly';
  static const String yearlyPlanId = 'yearly';
  static const String lifetimePlanId = 'lifetime';

  // Test Types
  static const String chapterTest = 'chapter';
  static const String comprehensiveTest = 'comprehensive';
  static const String examTest = 'exam';

  // URLs
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
  static const String supportEmail = 'support@yourapp.com';
  static const String appStoreUrl = 'https://apps.apple.com/app/your-app';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=your.app';

  // Error Messages
  static const String networkError = 'network_error';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';
  static const String authError = 'authentication_error';
  static const String premiumRequired = 'premium_required';

  // Success Messages
  static const String loginSuccess = 'login_success';
  static const String registrationSuccess = 'registration_success';
  static const String testCompleted = 'test_completed';
  static const String profileUpdated = 'profile_updated';
}