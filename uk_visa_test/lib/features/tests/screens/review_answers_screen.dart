// lib/features/tests/screens/review_answers_screen.dart - ENHANCED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../../../shared/providers/bilingual_provider.dart';
import '../../../data/models/attempt_model.dart';
import '../widgets/language_settings_bottom_sheet.dart';
import '../widgets/review_question_navigation_sheet.dart';
import '../widgets/enhanced_review_question_widget.dart';

class ReviewAnswersScreen extends ConsumerStatefulWidget {
  final int attemptId;

  const ReviewAnswersScreen({
    super.key,
    required this.attemptId,
  });

  @override
  ConsumerState<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends ConsumerState<ReviewAnswersScreen> {
  late PageController _pageController;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attemptDetailState = ref.watch(attemptDetailProvider(widget.attemptId));
    final showVietnamese = ref.watch(shouldShowVietnameseProvider);

    return attemptDetailState.when(
      data: (attempt) {
        final answers = attempt.answers ?? [];

        if (answers.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.review_answers ?? 'Review Answers'),
            ),
            body: Center(
              child: Text(l10n.no_answers_found ?? 'No answers found'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // 🔥 SLIVER APP BAR WITH PROGRESS
              _buildSliverAppBar(context, attempt, answers, theme, isDark),

              // 🔥 QUESTION CONTENT
              SliverFillRemaining(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    return EnhancedReviewQuestionWidget(
                      answer: answer,
                      questionNumber: index + 1,
                      totalQuestions: answers.length,
                      showVietnamese: showVietnamese,
                    );
                  },
                ),
              ),
            ],
          ),

          // 🔥 FIXED BOTTOM ACTION BAR
          bottomNavigationBar: _buildBottomActionBar(context, answers, theme, isDark),
        );
      },
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
        body: const Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(attemptDetailProvider(widget.attemptId)),
        ),
      ),
    );
  }

  // 🔥 SLIVER APP BAR WITH PROGRESS AND RESULT INFO
  Widget _buildSliverAppBar(BuildContext context, TestAttempt attempt, List<AttemptAnswer> answers, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final totalQuestions = answers.length;
    final progress = totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;
    final correctCount = answers.where((a) => a.isCorrect).length;

    // Theme-aware colors
    final appBarBackground = attempt.isPassed
        ? (isDark ? AppColors.success.withOpacity(0.8) : AppColors.success)
        : (isDark ? AppColors.error.withOpacity(0.8) : AppColors.error);
    final appBarForeground = Colors.white;
    final progressBackground = Colors.white.withOpacity(0.3);
    final progressValue = Colors.white;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: appBarForeground),
      ),
      title: Text(
        l10n.review_answers ?? 'Review Answers',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appBarForeground,
        ),
      ),
      actions: [
        // Language Settings
        IconButton(
          onPressed: () => _showLanguageSettings(context),
          icon: Icon(Icons.language, color: appBarForeground),
          tooltip: 'Language Settings',
        ),

        // Question Navigation
        IconButton(
          onPressed: () => _showQuestionNavigation(context, attempt, answers),
          icon: Icon(Icons.list, color: appBarForeground),
          tooltip: 'Question List',
        ),

      ],
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: attempt.isPassed
                  ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                  : [AppColors.error, AppColors.error.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Test Result Summary
                  Row(
                    children: [
                      Icon(
                        attempt.isPassed ? Icons.check_circle : Icons.cancel,
                        color: appBarForeground,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attempt.isPassed
                              ? (l10n.test_passed ?? 'Test Passed!')
                              : (l10n.test_failed ?? 'Test Failed'),
                          style: TextStyle(
                            color: appBarForeground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${attempt.percentage?.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: appBarForeground,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Info
                  Text(
                    'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                    style: TextStyle(
                      color: appBarForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Linear Progress Bar
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: progressBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(progressValue),
                    minHeight: 6,
                  ),

                  const SizedBox(height: 8),

                  // Score Summary
                  Row(
                    children: [
                      Text(
                        '${l10n.correct ?? 'Correct'}: $correctCount/$totalQuestions',
                        style: TextStyle(
                          color: appBarForeground.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (attempt.timeTakenInt > 0)
                        Text(
                          'Time: ${_formatTime(attempt.timeTakenInt)}',
                          style: TextStyle(
                            color: appBarForeground.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 FIXED BOTTOM ACTION BAR
  Widget _buildBottomActionBar(BuildContext context, List<AttemptAnswer> answers, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final totalQuestions = answers.length;
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex >= totalQuestions - 1;
    final currentAnswer = answers[_currentQuestionIndex];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question Status Indicator
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //   decoration: BoxDecoration(
              //     color: currentAnswer.isCorrect
              //         ? AppColors.success.withOpacity(0.1)
              //         : AppColors.error.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //       color: currentAnswer.isCorrect ? AppColors.success : AppColors.error,
              //     ),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(
              //         currentAnswer.isCorrect ? Icons.check_circle : Icons.cancel,
              //         color: currentAnswer.isCorrect ? AppColors.success : AppColors.error,
              //         size: 16,
              //       ),
              //       const SizedBox(width: 4),
              //       Text(
              //         currentAnswer.isCorrect
              //             ? (l10n.correct_answer ?? 'Correct')
              //             : (l10n.incorrect_answer ?? 'Incorrect'),
              //         style: TextStyle(
              //           color: currentAnswer.isCorrect ? AppColors.success : AppColors.error,
              //           fontWeight: FontWeight.bold,
              //           fontSize: 12,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 12),

              // Navigation Buttons
              Row(
                children: [
                  // Previous Button
                  if (!isFirstQuestion) ...[
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(l10n.previous ?? 'Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.primary.withOpacity(0.3)
                          ),
                          foregroundColor: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Next/Close Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isLastQuestion
                          ? () => context.pop()
                          : _nextQuestion,
                      icon: Icon(
                        isLastQuestion ? Icons.close : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(isLastQuestion ? (l10n.close ?? 'Close') : (l10n.next ?? 'Next')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSettingsBottomSheet(),
    );
  }

  void _showQuestionNavigation(BuildContext context, TestAttempt attempt, List<AttemptAnswer> answers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewQuestionNavigationSheet(
        attempt: attempt,
        answers: answers,
        currentQuestionIndex: _currentQuestionIndex,
        onQuestionTap: (index) {
          Navigator.pop(context);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Review Options',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vietnamese Toggle
                  Consumer(
                    builder: (context, ref, child) {
                      final showVietnamese = ref.watch(shouldShowVietnameseProvider);
                      return ListTile(
                        leading: Icon(
                          Icons.language,
                          color: AppColors.primary,
                        ),
                        title: Text('Vietnamese Support'),
                        subtitle: Text('Show Vietnamese translations'),
                        trailing: Switch(
                          value: showVietnamese,
                          onChanged: (value) {
                            ref.read(bilingualProvider.notifier).setBilingualMode(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                        onTap: () {
                          ref.read(bilingualProvider.notifier).toggleBilingual();
                        },
                      );
                    },
                  ),

                  const Divider(),

                  // Back to Test Result
                  ListTile(
                    leading: Icon(
                      Icons.assessment,
                      color: AppColors.info,
                    ),
                    title: Text('Back to Results'),
                    subtitle: Text('Return to test result summary'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      context.pop(); // Go back to result screen
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }
}