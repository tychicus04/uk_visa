import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/enhanced_question_widget.dart';
import '../widgets/language_settings_bottom_sheet.dart';
import '../widgets/question_navigation_sheet.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  const TestTakingScreen({
    super.key,
    required this.testId,
    this.attemptId,
  });

  final int testId;
  final int? attemptId;

  @override
  ConsumerState<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends ConsumerState<TestTakingScreen> {
  PageController? _pageController;
  int _currentQuestionIndex = 0;
  late Map<String, List<String>> _answers;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _answers = {};
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final testState = ref.watch(testDetailProvider(widget.testId));

    return testState.when(
      data: (test) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: CustomScrollView(
          slivers: [
            // 🔥 SLIVER APP BAR WITH PROGRESS
            _buildSliverAppBar(context, test, theme, isDark),

            // 🔥 QUESTION CONTENT
            SliverFillRemaining(
              child: test.questions != null
                  ? PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemCount: test.questions!.length,
                itemBuilder: (context, index) {
                  final question = test.questions![index];
                  return EnhancedQuestionWidget(
                    question: question,
                    questionNumber: index + 1,
                    totalQuestions: test.questions!.length,
                    selectedAnswers: _answers[question.id] ?? [],
                    onAnswerSelected: (answerId, isSelected) {
                      _handleAnswerSelection(question, answerId, isSelected);
                    },
                  );
                },
              )
                  : const Center(child: LoadingWidget()),
            ),
          ],
        ),

        // 🔥 FIXED BOTTOM ACTION BAR
        bottomNavigationBar: _buildBottomActionBar(context, test, theme, isDark),
      ),
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
        body: const Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(testDetailProvider(widget.testId)),
        ),
      ),
    );
  }

  // 🔥 SLIVER APP BAR WITH PROGRESS AND TIMER
  Widget _buildSliverAppBar(BuildContext context, dynamic test, ThemeData theme, bool isDark) {
    final totalQuestions = test.questions?.length ?? 24;
    final progress = totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;

    // Theme-aware colors
    final appBarBackground = isDark ? AppColors.surfaceDark : AppColors.primary;
    final appBarForeground = isDark ? AppColors.textPrimaryDark : Colors.white;
    final progressBackground = isDark
        ? AppColors.borderDark
        : Colors.white.withOpacity(0.3);
    final progressValue = isDark ? AppColors.primary : Colors.white;

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      leading: IconButton(
        onPressed: () => _showExitDialog(context),
        icon: Icon(Icons.close, color: appBarForeground),
      ),
      title: Text(
        test.displayTitle,
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
          onPressed: () => _showQuestionNavigation(context, test),
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
              colors: isDark
                  ? [AppColors.surfaceDark, AppColors.cardDark]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Row(
                children: [
                  // Progress Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                          style: TextStyle(
                            color: appBarForeground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Linear Progress Bar
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: progressBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(progressValue),
                          minHeight: 6,
                        ),

                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).round()}% Complete',
                          style: TextStyle(
                            color: appBarForeground.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Circular Timer
                  CircularTimerWidget(
                    totalDuration: const Duration(minutes: 45),
                    onTimeUp: () => _submitTest(context, ref),
                    isDarkMode: isDark,
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
  Widget _buildBottomActionBar(BuildContext context, dynamic test, ThemeData theme, bool isDark) {
    final totalQuestions = test.questions?.length ?? 24;
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex >= totalQuestions - 1;
    final answeredCount = _answers.values.where((answers) => answers.isNotEmpty).length;

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
          child: Row(
            children: [
              // Previous Button
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

              // Next/Submit Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isLastQuestion
                      ? () => _submitTest(context, ref)
                      : _nextQuestion,
                  icon: Icon(
                    isLastQuestion ? Icons.check : Icons.arrow_forward,
                    size: 18,
                  ),
                  label: Text(isLastQuestion ? 'Submit' : 'Next'),
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
        ),
      ),
    );
  }

  void _handleAnswerSelection(dynamic question, String answerId, bool isSelected) {
    setState(() {
      if (question.questionType == 'radio') {
        _answers[question.id] = isSelected ? [answerId] : [];
      } else {
        final currentAnswers = _answers[question.id] ?? [];
        if (isSelected) {
          if (!currentAnswers.contains(answerId)) {
            _answers[question.id] = [...currentAnswers, answerId];
          }
        } else {
          _answers[question.id] = currentAnswers.where((id) => id != answerId).toList();
        }
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    _pageController?.nextPage(
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

  void _showQuestionNavigation(BuildContext context, dynamic test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionNavigationSheet(
        test: test,
        currentQuestionIndex: _currentQuestionIndex,
        answers: _answers,
        onQuestionTap: (index) {
          Navigator.pop(context);
          _pageController?.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Future<void> _submitTest(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Submit Test',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to submit your test? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final timeTaken = DateTime.now().difference(_startTime).inSeconds;
        final attemptId = await ref.read(testProvider.notifier).submitAttempt(
          attemptIdParam: widget.attemptId!,
          answers: _answers,
          timeTaken: timeTaken,
        );

        if (context.mounted) {
          context.go('/tests/result/$attemptId');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Exit Test',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to exit? Your progress will be lost.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}