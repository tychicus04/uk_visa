// lib/features/tests/screens/test_taking_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../widgets/question_widget.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  final int testId;
  final int? attemptId;

  const TestTakingScreen({
    super.key,
    required this.testId,
    this.attemptId,
  });

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
    final testState = ref.watch(testDetailProvider(widget.testId));

    return testState.when(
      data: (test) => Scaffold(
        appBar: AppBar(
          title: Text(test.title ?? 'Test ${test.testNumber}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptionsMenu(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.test_questionOf(
                          _currentQuestionIndex + 1,
                          test.questions?.length ?? 24,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '0:03', // TODO: Implement timer
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / (test.questions?.length ?? 24),
                    backgroundColor: AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            ),

            // Questions
            Expanded(
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: QuestionWidget(
                      question: question,
                      selectedAnswers: _answers[question.id] ?? [],
                      onAnswerSelected: (answerId, isSelected) {
                        _handleAnswerSelection(question, answerId, isSelected);
                      },
                    ),
                  );
                },
              )
                  : const Center(child: LoadingWidget()),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back),
                        label: Text(l10n.common_previous),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentQuestionIndex < (test.questions?.length ?? 0) - 1
                          ? _nextQuestion
                          : () => _submitTest(context, ref),
                      icon: Icon(
                        _currentQuestionIndex < (test.questions?.length ?? 0) - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                      ),
                      label: Text(
                        _currentQuestionIndex < (test.questions?.length ?? 0) - 1
                            ? l10n.common_next
                            : l10n.test_submitTest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(testDetailProvider(widget.testId)),
        ),
      ),
    );
  }

  void _handleAnswerSelection(dynamic question, String answerId, bool isSelected) {
    setState(() {
      if (question.questionType == 'radio') {
        // Single selection
        _answers[question.id] = isSelected ? [answerId] : [];
      } else {
        // Multiple selection
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

  Future<void> _submitTest(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test'),
        content: const Text('Are you sure you want to submit your test? You cannot change your answers after submission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
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
            ),
          );
        }
      }
    }
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Mark for Review'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement mark for review
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Test Instructions'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Show instructions
              },
            ),
          ],
        ),
      ),
    );
  }
}
