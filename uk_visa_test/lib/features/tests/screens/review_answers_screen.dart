import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/attempt_model.dart';
import '../../../shared/providers/bilingual_provider.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/constants/api_constants.dart';
import '../providers/test_provider.dart';
import '../widgets/enhanced_review_question_widget.dart';
import '../widgets/language_settings_bottom_sheet.dart';
import '../widgets/review_question_navigation_sheet.dart';

class ReviewAnswersScreen extends ConsumerStatefulWidget {

  const ReviewAnswersScreen({
    super.key,
    required this.attemptId,
  });
  final int attemptId;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🆕 ENHANCED: Use dynamic bilingual state instead of deprecated Vietnamese provider
    final bilingualState = ref.watch(bilingualProvider);
    final attemptDetailState = ref.watch(attemptDetailProvider(widget.attemptId));

    return attemptDetailState.when(
      data: (attempt) {
        final answers = attempt.answers ?? [];

        if (answers.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Review Answers'),
            ),
            body: const Center(
              child: Text('No answers found'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, attempt, answers, bilingualState, theme, isDark),

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

  // 🔥 ENHANCED: Sliver App Bar with Dynamic Language Support
  Widget _buildSliverAppBar(BuildContext context, TestAttempt attempt, List<AttemptAnswer> answers, bilingualState, ThemeData theme, bool isDark) {
    final totalQuestions = answers.length;
    final progress = totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;
    final correctCount = answers.where((a) => a.isCorrect).length;
    final appBarBackground = attempt.isPassed
        ? (isDark ? AppColors.success.withValues(alpha: 0.8) : AppColors.success)
        : (isDark ? AppColors.error.withValues(alpha: 0.8) : AppColors.error);
    const appBarForeground = Colors.white;
    final progressBackground = Colors.white.withValues(alpha: 0.3);
    const progressValue = Colors.white;

    return SliverAppBar(
      expandedHeight: 180, // Increased height for language info
      pinned: true,
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      leading: IconButton(
        onPressed: () => context.go('/tests/result/${widget.attemptId}'),
        icon: const Icon(Icons.arrow_back, color: appBarForeground),
      ),
      title: const Text(
        'Review Answers',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appBarForeground,
        ),
      ),
      actions: [
        // Language Settings
        IconButton(
          onPressed: () => _showLanguageSettings(context),
          icon: Stack(
            children: [
              const Icon(Icons.language, color: appBarForeground),
              // Language indicator badge
              if (bilingualState.isEnabled)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(color: appBarForeground, width: 1),
                    ),
                  ),
                ),
            ],
          ),
          tooltip: 'Language Settings',
        ),

        // Question Navigation
        IconButton(
          onPressed: () => _showQuestionNavigation(context, attempt, answers),
          icon: const Icon(Icons.list, color: appBarForeground),
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
                  ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
                  : [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                              ? 'Test Passed!'
                              : 'Test Failed',
                          style: const TextStyle(
                            color: appBarForeground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${attempt.percentage?.toStringAsFixed(1)}%',
                          style: const TextStyle(
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
                    style: const TextStyle(
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

                  // Score and Language Info Row
                  Row(
                    children: [
                      Text(
                        'Correct: $correctCount/$totalQuestions',
                        style: TextStyle(
                          color: appBarForeground.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (attempt.timeTakenInt > 0)
                        Text(
                          'Time: ${_formatTime(attempt.timeTakenInt)}',
                          style: TextStyle(
                            color: appBarForeground.withValues(alpha: 0.9),
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
    final totalQuestions = answers.length;
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex >= totalQuestions - 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (!isFirstQuestion) ...[
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.primary.withValues(alpha: 0.3)
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
                          ? () => context.go('/tests/result/${widget.attemptId}')
                          : _nextQuestion,
                      icon: Icon(
                        isLastQuestion ? Icons.close : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(isLastQuestion ? 'Close' : 'Next'),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }
}