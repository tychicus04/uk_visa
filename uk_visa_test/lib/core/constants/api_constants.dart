// lib/core/constants/api_constants.dart
class ApiConstants {
  // App Info
  static const String appName = 'Life in the UK';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'British Citizenship Test Preparation';

  // Test Configuration
  static const int testTimeLimit = 45; // minutes
  static const int testQuestionCount = 24;
  static const double passingScore = 75.0; // percentage
  static const int freeTestLimit = 5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheTimeout = Duration(hours: 1);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'vi'];
  static const String defaultLanguage = 'en';

  // URLs
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportUrl = 'https://example.com/support';

  // Test Types
  static const String testTypeChapter = 'chapter';
  static const String testTypeComprehensive = 'comprehensive';
  static const String testTypeExam = 'exam';

  // Question Types
  static const String questionTypeRadio = 'radio';
  static const String questionTypeCheckbox = 'checkbox';

  // Base URLs
  static const String baseUrl = 'http://10.0.2.2/UKVisa/backend';
  static const String apiVersion = 'v1';

  // Auth Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authChangePassword = '/auth/change-password';
  static const String authLanguage = '/auth/language';

  // Test Endpoints
  static const String testsAvailable = '/tests/available';
  static const String testsFree = '/tests/free';
  static const String testsSearch = '/tests/search';
  static const String testDetail = '/tests'; // + /{id}
  static const String testByType = '/tests/type'; // + /{type}
  static const String testByChapter = '/tests/chapter'; // + /{chapterId}

  // Attempt Endpoints
  static const String attemptsStart = '/attempts/start';
  static const String attemptsSubmit = '/attempts/submit';
  static const String attemptsHistory = '/attempts/history';
  static const String attemptDetail = '/attempts'; // + /{id}

  // Chapter Endpoints
  static const String chapters = '/chapters';
  static const String chapterDetail = '/chapters'; // + /{id}

  // Subscription Endpoints
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscriptionSubscribe = '/subscriptions/subscribe';
  static const String subscriptionStatus = '/subscriptions/status';

  // Question Endpoints
  static const String questions = '/questions';
  static const String questionsByTest = '/questions/test'; // + /{test_id}

  // System Endpoints
  static const String health = '/health';
  static const String test = '/test';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const String paramIncludeVietnamese = 'include_vietnamese';
  static const String paramIncludeAnswers = 'include_answers';
  static const String paramLanguageCode = 'language_code';
  static const String paramBilingualMode = 'bilingual_mode';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);

  // NEW: Test filtering and grouping helpers
  static Map<String, List<String>> get testGroupings => {
    'practice': [testTypeChapter, testTypeComprehensive],
    'exam': [testTypeExam],
  };

  // NEW: Test type display names
  static Map<String, String> get testTypeDisplayNames => {
    testTypeChapter: 'Chapter',
    testTypeComprehensive: 'Mixed',
    testTypeExam: 'Exam',
  };

  // NEW: Test type icons
  static Map<String, String> get testTypeIcons => {
    testTypeChapter: 'book',
    testTypeComprehensive: 'quiz',
    testTypeExam: 'assignment',
  };

  // NEW: Helper methods
  static bool isPracticeTest(String testType) {
    return testGroupings['practice']!.contains(testType);
  }

  static bool isExamTest(String testType) {
    return testGroupings['exam']!.contains(testType);
  }

  static String getTestTypeDisplayName(String testType) {
    return testTypeDisplayNames[testType] ?? testType;
  }
}


