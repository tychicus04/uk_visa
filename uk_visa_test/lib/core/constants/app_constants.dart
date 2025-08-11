class AppConstants {
// API
static const String baseUrl = 'http://localhost/UKVisa/backend';
static const String apiVersion = 'v1';

// Storage Keys
static const String tokenKey = 'auth_token';
static const String userKey = 'user_data';
static const String languageKey = 'app_language';
static const String themeKey = 'app_theme';
static const String subscriptionModalShownKey = 'has_shown_subscription_modal'; // NEW

// App Config
static const int freeTestLimit = 5;
static const int questionsPerTest = 24;
static const int passingScore = 18; // 75%

// Subscription - NEW
static const String weeklyProductId = 'com.ukvisatest.weekly_premium';
static const String unlimitedProductId = 'com.ukvisatest.unlimited_premium';

// Timeouts
static const Duration apiTimeout = Duration(seconds: 30);
static const Duration connectTimeout = Duration(seconds: 15);

// Pagination
static const int defaultPageSize = 20;
static const int maxPageSize = 100;
}