import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'UK Visa Test'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Life in the UK Practice Test'**
  String get appDescription;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get tests;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your UK Visa preparation'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to UK citizenship'**
  String get registerSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginSuccess;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get registrationSuccess;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccess;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists'**
  String get emailAlreadyExists;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get accountNotFound;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again'**
  String get sessionExpired;

  /// No description provided for @practiceTests.
  ///
  /// In en, this message translates to:
  /// **'Practice Tests'**
  String get practiceTests;

  /// No description provided for @chapterTests.
  ///
  /// In en, this message translates to:
  /// **'Chapter Tests'**
  String get chapterTests;

  /// No description provided for @comprehensiveTests.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Tests'**
  String get comprehensiveTests;

  /// No description provided for @examTests.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get examTests;

  /// No description provided for @freeTests.
  ///
  /// In en, this message translates to:
  /// **'Free Tests'**
  String get freeTests;

  /// No description provided for @premiumTests.
  ///
  /// In en, this message translates to:
  /// **'Premium Tests'**
  String get premiumTests;

  /// No description provided for @allTests.
  ///
  /// In en, this message translates to:
  /// **'All Tests'**
  String get allTests;

  /// No description provided for @myTests.
  ///
  /// In en, this message translates to:
  /// **'My Tests'**
  String get myTests;

  /// No description provided for @completedTests.
  ///
  /// In en, this message translates to:
  /// **'Completed Tests'**
  String get completedTests;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @retakeTest.
  ///
  /// In en, this message translates to:
  /// **'Retake Test'**
  String get retakeTest;

  /// No description provided for @continueTest.
  ///
  /// In en, this message translates to:
  /// **'Continue Test'**
  String get continueTest;

  /// No description provided for @testResults.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get testResults;

  /// No description provided for @testHistory.
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get testHistory;

  /// No description provided for @testDetails.
  ///
  /// In en, this message translates to:
  /// **'Test Details'**
  String get testDetails;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Question} other{{count} Questions}}'**
  String questionsCount(int count);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @timeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time Taken'**
  String get timeTaken;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get needsImprovement;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well Done!'**
  String get wellDone;

  /// No description provided for @keepTrying.
  ///
  /// In en, this message translates to:
  /// **'Keep Trying!'**
  String get keepTrying;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @noTestsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tests available'**
  String get noTestsAvailable;

  /// No description provided for @searchTests.
  ///
  /// In en, this message translates to:
  /// **'Search tests...'**
  String get searchTests;

  /// No description provided for @filterTests.
  ///
  /// In en, this message translates to:
  /// **'Filter Tests'**
  String get filterTests;

  /// No description provided for @sortTests.
  ///
  /// In en, this message translates to:
  /// **'Sort Tests'**
  String get sortTests;

  /// No description provided for @testDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get testDifficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attempts;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// No description provided for @passRate.
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get passRate;

  /// No description provided for @submitTest.
  ///
  /// In en, this message translates to:
  /// **'Submit Test'**
  String get submitTest;

  /// No description provided for @submitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit this test?'**
  String get submitConfirmation;

  /// No description provided for @cannotUndoSubmit.
  ///
  /// In en, this message translates to:
  /// **'You cannot undo this action.'**
  String get cannotUndoSubmit;

  /// No description provided for @testSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Test submitted successfully!'**
  String get testSubmitted;

  /// No description provided for @testIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions before submitting'**
  String get testIncomplete;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select an answer'**
  String get selectAnswer;

  /// No description provided for @selectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Select all correct answers'**
  String get selectAnswers;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @singleChoice.
  ///
  /// In en, this message translates to:
  /// **'Single Choice'**
  String get singleChoice;

  /// No description provided for @previousQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousQuestion;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextQuestion;

  /// No description provided for @markForReview.
  ///
  /// In en, this message translates to:
  /// **'Mark for Review'**
  String get markForReview;

  /// No description provided for @reviewMarked.
  ///
  /// In en, this message translates to:
  /// **'Review Marked'**
  String get reviewMarked;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @chapterNumber.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterNumber(int number);

  /// No description provided for @chapter1.
  ///
  /// In en, this message translates to:
  /// **'The Values and Principles of the UK'**
  String get chapter1;

  /// No description provided for @chapter2.
  ///
  /// In en, this message translates to:
  /// **'What is the UK?'**
  String get chapter2;

  /// No description provided for @chapter3.
  ///
  /// In en, this message translates to:
  /// **'A Long and Illustrious History'**
  String get chapter3;

  /// No description provided for @chapter4.
  ///
  /// In en, this message translates to:
  /// **'A Modern, Thriving Society'**
  String get chapter4;

  /// No description provided for @chapter5.
  ///
  /// In en, this message translates to:
  /// **'The UK Government, the Law and Your Role'**
  String get chapter5;

  /// No description provided for @chapterProgress.
  ///
  /// In en, this message translates to:
  /// **'Chapter Progress'**
  String get chapterProgress;

  /// No description provided for @testsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tests Completed'**
  String get testsCompleted;

  /// No description provided for @testsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Tests Remaining'**
  String get testsRemaining;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @unlimitedTests.
  ///
  /// In en, this message translates to:
  /// **'Unlimited test attempts'**
  String get unlimitedTests;

  /// No description provided for @allPremiumTests.
  ///
  /// In en, this message translates to:
  /// **'Access to all premium tests'**
  String get allPremiumTests;

  /// No description provided for @detailedExplanations.
  ///
  /// In en, this message translates to:
  /// **'Detailed explanations for all questions'**
  String get detailedExplanations;

  /// No description provided for @progressTracking.
  ///
  /// In en, this message translates to:
  /// **'Advanced progress tracking'**
  String get progressTracking;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority customer support'**
  String get prioritySupport;

  /// No description provided for @adFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFree;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium Only'**
  String get premiumOnly;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get choosePlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// No description provided for @lifetimePlan.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access'**
  String get lifetimePlan;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(int percent);

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'\${price}/month'**
  String pricePerMonth(String price);

  /// No description provided for @pricePerYear.
  ///
  /// In en, this message translates to:
  /// **'\${price}/year'**
  String pricePerYear(String price);

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-time payment of \${price}'**
  String oneTimePayment(String price);

  /// No description provided for @subscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription is active'**
  String get subscriptionActive;

  /// No description provided for @subscriptionExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String subscriptionExpires(String date);

  /// No description provided for @freeTestsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} free tests remaining'**
  String freeTestsRemaining(int count);

  /// No description provided for @freeTestsUsed.
  ///
  /// In en, this message translates to:
  /// **'You have used all your free tests'**
  String get freeTestsUsed;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription required'**
  String get premiumRequired;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total Attempts'**
  String get totalAttempts;

  /// No description provided for @totalTests.
  ///
  /// In en, this message translates to:
  /// **'Total Tests'**
  String get totalTests;

  /// No description provided for @studyStreak.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get studyStreak;

  /// No description provided for @favoriteChapter.
  ///
  /// In en, this message translates to:
  /// **'Favorite Chapter'**
  String get favoriteChapter;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get confirmDelete;

  /// No description provided for @cannotUndoDelete.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotUndoDelete;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @studyReminders.
  ///
  /// In en, this message translates to:
  /// **'Study Reminders'**
  String get studyReminders;

  /// No description provided for @testReminders.
  ///
  /// In en, this message translates to:
  /// **'Test Reminders'**
  String get testReminders;

  /// No description provided for @achievementNotifications.
  ///
  /// In en, this message translates to:
  /// **'Achievement Notifications'**
  String get achievementNotifications;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @autoLogin.
  ///
  /// In en, this message translates to:
  /// **'Auto Login'**
  String get autoLogin;

  /// No description provided for @dataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout'**
  String get connectionTimeout;

  /// No description provided for @invalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response'**
  String get invalidResponse;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Access forbidden'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get notFound;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error'**
  String get paymentError;

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Subscription error'**
  String get subscriptionError;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkConnection;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Please contact support if the problem persists'**
  String get contactSupport;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @operationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get operationSuccessful;

  /// No description provided for @dataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get dataUpdated;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSaved;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// No description provided for @subscriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated successfully'**
  String get subscriptionUpdated;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistory;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to UK Visa Test'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your complete guide to passing the Life in the UK Test'**
  String get welcomeDescription;

  /// No description provided for @feature1Title.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Practice'**
  String get feature1Title;

  /// No description provided for @feature1Description.
  ///
  /// In en, this message translates to:
  /// **'Practice with authentic questions covering all 5 chapters'**
  String get feature1Description;

  /// No description provided for @feature2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get feature2Title;

  /// No description provided for @feature2Description.
  ///
  /// In en, this message translates to:
  /// **'Monitor your improvement with detailed statistics'**
  String get feature2Description;

  /// No description provided for @feature3Title.
  ///
  /// In en, this message translates to:
  /// **'Expert Explanations'**
  String get feature3Title;

  /// No description provided for @feature3Description.
  ///
  /// In en, this message translates to:
  /// **'Learn from detailed explanations for every question'**
  String get feature3Description;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @testPassedTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get testPassedTitle;

  /// No description provided for @testPassedMessage.
  ///
  /// In en, this message translates to:
  /// **'You passed the test with {score}%'**
  String testPassedMessage(String score);

  /// No description provided for @testFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing!'**
  String get testFailedTitle;

  /// No description provided for @testFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'You scored {score}%. You need 75% to pass.'**
  String testFailedMessage(String score);

  /// No description provided for @perfectScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score!'**
  String get perfectScoreTitle;

  /// No description provided for @perfectScoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! You got all questions correct!'**
  String get perfectScoreMessage;

  /// No description provided for @firstPassTitle.
  ///
  /// In en, this message translates to:
  /// **'First Pass!'**
  String get firstPassTitle;

  /// No description provided for @firstPassMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on passing this test for the first time!'**
  String get firstPassMessage;

  /// No description provided for @improvementTitle.
  ///
  /// In en, this message translates to:
  /// **'Great Improvement!'**
  String get improvementTitle;

  /// No description provided for @improvementMessage.
  ///
  /// In en, this message translates to:
  /// **'You improved your score by {points} points!'**
  String improvementMessage(int points);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
