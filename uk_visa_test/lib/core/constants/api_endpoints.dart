class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';

  // Tests
  static const String availableTests = '/tests/available';
  static const String freeTests = '/tests/free';
  static const String searchTests = '/tests/search';
  static String testById(int id) => '/tests/$id';
  static String testsByType(String type) => '/tests/type/$type';
  static String testsByChapter(int chapterId) => '/tests/chapter/$chapterId';

  // Attempts
  static const String startAttempt = '/attempts/start';
  static const String submitAttempt = '/attempts/submit';
  static const String attemptHistory = '/attempts/history';
  static const String retakeTest = '/attempts/retake';
  static String attemptDetails(int id) => '/attempts/$id';

  // Chapters
  static const String chapters = '/chapters';
  static String chapterById(int id) => '/chapters/$id';

  // Subscriptions
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';
  static const String subscriptionStatus = '/subscriptions/status';
  static const String cancelSubscription = '/subscriptions/cancel';

  // System
  static const String health = '/health';
  static const String test = '/test';
}