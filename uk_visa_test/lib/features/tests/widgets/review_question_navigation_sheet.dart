// lib/features/tests/widgets/review_question_navigation_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/attempt_model.dart';

class ReviewQuestionNavigationSheet extends ConsumerWidget {
  final TestAttempt attempt;
  final List<AttemptAnswer> answers;
  final int currentQuestionIndex;
  final Function(int) onQuestionTap;

  const ReviewQuestionNavigationSheet({
    super.key,
    required this.attempt,
    required this.answers,
    required this.currentQuestionIndex,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final correctCount = answers.where((a) => a.isCorrect).length;
    final incorrectCount = answers.length - correctCount;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
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
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Questions',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${answers.length} questions total',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Summary Statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: attempt.isPassed
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: attempt.isPassed ? AppColors.success : AppColors.error,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Overall Result
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              attempt.isPassed ? Icons.check_circle : Icons.cancel,
                              color: attempt.isPassed ? AppColors.success : AppColors.error,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${attempt.percentage?.toStringAsFixed(1)}%',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: attempt.isPassed ? AppColors.success : AppColors.error,
                              ),
                            ),
                            Text(
                              attempt.isPassed ? 'Passed' : 'Failed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: attempt.isPassed ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 60,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),

                      // Correct Answers
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$correctCount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              'Correct',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 60,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),

                      // Incorrect Answers
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel,
                              color: AppColors.error,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$incorrectCount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              'Incorrect',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Legend
                Row(
                  children: [
                    Text(
                      'Legend:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      context,
                      color: AppColors.success,
                      label: 'Correct',
                      icon: Icons.check,
                    ),
                    const SizedBox(width: 12),
                    _buildLegendItem(
                      context,
                      color: AppColors.error,
                      label: 'Incorrect',
                      icon: Icons.close,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Questions Grid
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final answer = answers[index];
                        final isCurrent = index == currentQuestionIndex;

                        return GestureDetector(
                          onTap: () => onQuestionTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getQuestionColor(answer, isCurrent, isDark),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrent
                                    ? AppColors.primary
                                    : (answer.isCorrect ? AppColors.success : AppColors.error),
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: isCurrent
                                  ? Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Icon(
                                      answer.isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              )
                                  : Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Icon(
                                      answer.isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Jump to first incorrect question
                          final firstIncorrectIndex = answers.indexWhere((a) => !a.isCorrect);
                          if (firstIncorrectIndex != -1) {
                            onQuestionTap(firstIncorrectIndex);
                          }
                        },
                        icon: Icon(Icons.error_outline, color: AppColors.error),
                        label: Text(
                          'View Incorrect',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, {
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 10,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Color _getQuestionColor(AttemptAnswer answer, bool isCurrent, bool isDark) {
    if (isCurrent) {
      return AppColors.primary;
    }

    if (answer.isCorrect) {
      return AppColors.success;
    } else {
      return AppColors.error;
    }
  }
}