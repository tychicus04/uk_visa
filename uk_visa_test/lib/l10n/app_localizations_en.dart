// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UK Visa Test';

  @override
  String get appDescription => 'Life in the UK Practice Test';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get continueButton => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get save => 'Save';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get share => 'Share';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get viewAll => 'View All';

  @override
  String get seeMore => 'See More';

  @override
  String get showLess => 'Show Less';

  @override
  String get home => 'Home';

  @override
  String get tests => 'Tests';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get premium => 'Premium';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue your UK Visa preparation';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Start your journey to UK citizenship';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get agreeToTerms => 'I agree to the Terms of Service and Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get loginSuccess => 'Welcome back!';

  @override
  String get registrationSuccess => 'Account created successfully!';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get emailAlreadyExists => 'Email already exists';

  @override
  String get accountNotFound => 'Account not found';

  @override
  String get sessionExpired => 'Session expired. Please login again';

  @override
  String get practiceTests => 'Practice Tests';

  @override
  String get chapterTests => 'Chapter Tests';

  @override
  String get comprehensiveTests => 'Comprehensive Tests';

  @override
  String get examTests => 'Practice Exams';

  @override
  String get freeTests => 'Free Tests';

  @override
  String get premiumTests => 'Premium Tests';

  @override
  String get allTests => 'All Tests';

  @override
  String get myTests => 'My Tests';

  @override
  String get completedTests => 'Completed Tests';

  @override
  String get startTest => 'Start Test';

  @override
  String get retakeTest => 'Retake Test';

  @override
  String get continueTest => 'Continue Test';

  @override
  String get testResults => 'Test Results';

  @override
  String get testHistory => 'Test History';

  @override
  String get testDetails => 'Test Details';

  @override
  String get questions => 'Questions';

  @override
  String questionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Questions',
      one: '1 Question',
    );
    return '$_temp0';
  }

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get timeTaken => 'Time Taken';

  @override
  String get score => 'Score';

  @override
  String get percentage => 'Percentage';

  @override
  String get result => 'Result';

  @override
  String get passed => 'Passed';

  @override
  String get failed => 'Failed';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get average => 'Average';

  @override
  String get needsImprovement => 'Needs Improvement';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get wellDone => 'Well Done!';

  @override
  String get keepTrying => 'Keep Trying!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get explanation => 'Explanation';

  @override
  String get noTestsAvailable => 'No tests available';

  @override
  String get searchTests => 'Search tests...';

  @override
  String get filterTests => 'Filter Tests';

  @override
  String get sortTests => 'Sort Tests';

  @override
  String get testDifficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get duration => 'Duration';

  @override
  String get attempts => 'Attempts';

  @override
  String get bestScore => 'Best Score';

  @override
  String get averageScore => 'Average Score';

  @override
  String get passRate => 'Pass Rate';

  @override
  String get submitTest => 'Submit Test';

  @override
  String get submitConfirmation => 'Are you sure you want to submit this test?';

  @override
  String get cannotUndoSubmit => 'You cannot undo this action.';

  @override
  String get testSubmitted => 'Test submitted successfully!';

  @override
  String get testIncomplete => 'Please answer all questions before submitting';

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get selectAnswer => 'Select an answer';

  @override
  String get selectAnswers => 'Select all correct answers';

  @override
  String get multipleChoice => 'Multiple Choice';

  @override
  String get singleChoice => 'Single Choice';

  @override
  String get previousQuestion => 'Previous';

  @override
  String get nextQuestion => 'Next';

  @override
  String get markForReview => 'Mark for Review';

  @override
  String get reviewMarked => 'Review Marked';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get chapter => 'Chapter';

  @override
  String get chapters => 'Chapters';

  @override
  String chapterNumber(int number) {
    return 'Chapter $number';
  }

  @override
  String get chapter1 => 'The Values and Principles of the UK';

  @override
  String get chapter2 => 'What is the UK?';

  @override
  String get chapter3 => 'A Long and Illustrious History';

  @override
  String get chapter4 => 'A Modern, Thriving Society';

  @override
  String get chapter5 => 'The UK Government, the Law and Your Role';

  @override
  String get chapterProgress => 'Chapter Progress';

  @override
  String get testsCompleted => 'Tests Completed';

  @override
  String get testsRemaining => 'Tests Remaining';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get unlimitedTests => 'Unlimited test attempts';

  @override
  String get allPremiumTests => 'Access to all premium tests';

  @override
  String get detailedExplanations => 'Detailed explanations for all questions';

  @override
  String get progressTracking => 'Advanced progress tracking';

  @override
  String get prioritySupport => 'Priority customer support';

  @override
  String get adFree => 'Ad-free experience';

  @override
  String get premiumOnly => 'Premium Only';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get choosePlan => 'Choose Your Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get lifetimePlan => 'Lifetime Access';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get bestValue => 'Best Value';

  @override
  String savePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String pricePerMonth(String price) {
    return '\$$price/month';
  }

  @override
  String pricePerYear(String price) {
    return '\$$price/year';
  }

  @override
  String oneTimePayment(String price) {
    return 'One-time payment of \$$price';
  }

  @override
  String get subscriptionActive => 'Premium subscription is active';

  @override
  String subscriptionExpires(String date) {
    return 'Expires on $date';
  }

  @override
  String freeTestsRemaining(int count) {
    return '$count free tests remaining';
  }

  @override
  String get freeTestsUsed => 'You have used all your free tests';

  @override
  String get premiumRequired => 'Premium subscription required';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get myProfile => 'My Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get support => 'Support';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get followUs => 'Follow Us';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalAttempts => 'Total Attempts';

  @override
  String get totalTests => 'Total Tests';

  @override
  String get studyStreak => 'Study Streak';

  @override
  String get favoriteChapter => 'Favorite Chapter';

  @override
  String get achievements => 'Achievements';

  @override
  String get badges => 'Badges';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get confirmDelete => 'Are you sure you want to delete your account?';

  @override
  String get cannotUndoDelete => 'This action cannot be undone.';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get studyReminders => 'Study Reminders';

  @override
  String get testReminders => 'Test Reminders';

  @override
  String get achievementNotifications => 'Achievement Notifications';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get vibration => 'Vibration';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get autoLogin => 'Auto Login';

  @override
  String get dataSync => 'Data Sync';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get networkError => 'Network connection error';

  @override
  String get serverError => 'Server error. Please try again later';

  @override
  String get unknownError => 'Unknown error occurred';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get connectionTimeout => 'Connection timeout';

  @override
  String get invalidResponse => 'Invalid server response';

  @override
  String get unauthorized => 'Unauthorized access';

  @override
  String get forbidden => 'Access forbidden';

  @override
  String get notFound => 'Resource not found';

  @override
  String get validationError => 'Validation error';

  @override
  String get paymentError => 'Payment error';

  @override
  String get subscriptionError => 'Subscription error';

  @override
  String get tryAgainLater => 'Please try again later';

  @override
  String get checkConnection => 'Please check your internet connection';

  @override
  String get contactSupport => 'Please contact support if the problem persists';

  @override
  String get success => 'Success';

  @override
  String get operationSuccessful => 'Operation completed successfully';

  @override
  String get dataUpdated => 'Data updated successfully';

  @override
  String get changesSaved => 'Changes saved successfully';

  @override
  String get paymentSuccessful => 'Payment successful';

  @override
  String get subscriptionUpdated => 'Subscription updated successfully';

  @override
  String get searchHint => 'Search...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResults => 'No results found';

  @override
  String get searchHistory => 'Search History';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get welcomeTitle => 'Welcome to UK Visa Test';

  @override
  String get welcomeDescription => 'Your complete guide to passing the Life in the UK Test';

  @override
  String get feature1Title => 'Comprehensive Practice';

  @override
  String get feature1Description => 'Practice with authentic questions covering all 5 chapters';

  @override
  String get feature2Title => 'Track Your Progress';

  @override
  String get feature2Description => 'Monitor your improvement with detailed statistics';

  @override
  String get feature3Title => 'Expert Explanations';

  @override
  String get feature3Description => 'Learn from detailed explanations for every question';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get testPassedTitle => 'Congratulations!';

  @override
  String testPassedMessage(String score) {
    return 'You passed the test with $score%';
  }

  @override
  String get testFailedTitle => 'Keep Practicing!';

  @override
  String testFailedMessage(String score) {
    return 'You scored $score%. You need 75% to pass.';
  }

  @override
  String get perfectScoreTitle => 'Perfect Score!';

  @override
  String get perfectScoreMessage => 'Outstanding! You got all questions correct!';

  @override
  String get firstPassTitle => 'First Pass!';

  @override
  String get firstPassMessage => 'Congratulations on passing this test for the first time!';

  @override
  String get improvementTitle => 'Great Improvement!';

  @override
  String improvementMessage(int points) {
    return 'You improved your score by $points points!';
  }
}
