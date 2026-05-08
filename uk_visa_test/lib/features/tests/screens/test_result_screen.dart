import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';

class TestResultScreen extends ConsumerWidget {

  const TestResultScreen({
    required this.attemptId, super.key,
  });
  final int attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultState = ref.watch(attemptDetailProvider(attemptId));

    return resultState.when(
      data: (result) => Scaffold(
        appBar: AppBar(
          title: const Text('Test Results'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Force refresh test data before closing
                print('🏠 TestResultScreen: Force refreshing before going home');
                final _ = ref.refresh(availableTestsProvider);
                // Give a small delay for the refresh to start and then navigate
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    context.go('/');
                  }
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: result.isPassed
                        ? AppColors.successGradient
                        : [AppColors.error, AppColors.errorLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      result.isPassed ? Icons.check_circle : Icons.cancel,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.isPassed ? 'Test Passed!' : 'Test Failed',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: ${result.percentage?.toStringAsFixed(1) ?? '0'}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passing score: ${AppConstants.passingScorePercent.toInt()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Score Details
              Row(
                children: [
                  Expanded(
                    child: _buildScoreCard(
                      icon: Icons.check_circle,
                      label: 'Correct',
                      value: '${result.score}',
                      total: '${result.totalQuestions}',
                      color: AppColors.success,
                      theme: theme,
                    ),
                  ),
                  // 🔥 FIX: Only show time card for timed tests (exam mode)
                  if (result.testType?.toLowerCase() == 'exam' ||
                      result.testType?.toLowerCase() == 'comprehensive') ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildScoreCard(
                        icon: Icons.access_time,
                        label: 'Time Taken',
                        value: Helpers.formatTime(result.timeTakenInt),
                        total: _defaultTotalTimeLabel(result.testType),
                        color: AppColors.primary,
                        theme: theme,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  // ✅ Navigate to review answers screen
                  context.go('/review-answers/$attemptId');
                },
                icon: const Icon(Icons.reviews),
                label: const Text('Review Answers'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to retake test
                  final testId = result.testIdInt;
                  if (testId > 0) {
                    context.go('/tests/$testId');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retake Test'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () {
                  // Force refresh test data before going to home
                  print('🏠 TestResultScreen: Force refreshing before going home');
                  final _ = ref.refresh(availableTestsProvider);
                  // Give a small delay for the refresh to start and then navigate
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      context.go('/');
                    }
                  });
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: theme.brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 24),

              // Additional Test Information
              if (result.title != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.cardDark
                        : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Test',
                        result.title ?? 'Unknown',
                      ),
                      if (result.testNumber != null)
                        _buildInfoRow(
                          context,
                          'Test Number',
                          result.testNumber!,
                        ),
                      if (result.chapterName != null)
                        _buildInfoRow(
                          context,
                          'Chapter',
                          result.chapterName!,
                        ),
                      _buildInfoRow(
                        context,
                        'Completed At',
                        _formatDate(result.completedAt),
                      ),
                      if (result.timeTakenInt > 0)
                        _buildInfoRow(
                          context,
                          'Duration',
                          Helpers.formatTime(result.timeTakenInt),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(attemptDetailProvider(attemptId)),
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required IconData icon,
    required String label,
    required String value,
    required String total,
    required Color color,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'of $total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      String label,
      String value,
      ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mirrors Test.defaultTimeLimit so the result screen shows the right cap
  // per test type instead of always saying "45 minutes".
  String _defaultTotalTimeLabel(String? testType) {
    switch (testType?.toLowerCase()) {
      case 'exam':
        return '45 minutes';
      case 'comprehensive':
        return '30 minutes';
      case 'chapter':
        return '20 minutes';
      default:
        return '45 minutes';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}