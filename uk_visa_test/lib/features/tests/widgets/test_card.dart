import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/test_model.dart';

class TestCard extends StatelessWidget {

  const TestCard({
    required this.test,
    required this.onTap,
    super.key,
    this.displayNumber,
    this.showTestType = false,
  });
  final Test test;
  final VoidCallback onTap;
  final int? displayNumber;
  final bool showTestType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 4 : 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shadowColor: isDark ? AppColors.shadowDark : AppColors.shadowLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTestTypeColor(test.testType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getTestTypeColor(test.testType).withValues(alpha: isDark ? 0.3 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getTestTypeIcon(test.testType),
                      color: _getTestTypeColor(test.testType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayNumber != null 
                            ? _getDisplayTitleWithNumber(test, displayNumber!)
                            : test.displayTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (showTestType) ...[
                              _buildTestTypeBadge(context, isDark),
                            ],
                            if (test.chapterName != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  test.chapterName!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildAccessIndicator(context, isDark),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    context,
                    icon: Icons.quiz_outlined,
                    label: '${test.questionCountInt} Questions',
                    color: AppColors.info,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  if (test.attemptCountInt > 0) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.history,
                      label: '${test.attemptCountInt} Attempts',
                      color: AppColors.secondary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (test.bestScore != null) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.star_outlined,
                      label: '${test.bestScore!.toInt()}%',
                      color: _getScoreColor(test.bestScore!),
                      isDark: isDark,
                    ),
                  ],
                  const Spacer(),
                  _buildStatChip(
                    context,
                    icon: Icons.free_breakfast,
                    label: 'Free',
                    color: AppColors.success,
                    isDark: isDark,
                  )
                ],
              ),

              // Progress indicator if there are attempts
              if (test.attemptCountInt > 0 && test.bestScore != null) ...[
                const SizedBox(height: 12),
                _buildProgressIndicator(context, isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestTypeBadge(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    String label;
    switch (test.testType.toLowerCase()) {
      case 'chapter':
        label = 'Chapter';
        break;
      case 'comprehensive':
        label = 'Mixed';
        break;
      case 'exam':
        label = 'Exam';
        break;
      default:
        label = test.testType;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTestTypeColor(test.testType).withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getTestTypeColor(test.testType).withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getTestTypeColor(test.testType),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAccessIndicator(BuildContext context, bool isDark) {
    if (!test.isAccessible) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.error.withValues(alpha: isDark ? 0.3 : 0.2),
          ),
        ),
        child: const Icon(
          Icons.lock_outline,
          color: AppColors.error,
          size: 16,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.success.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.play_arrow,
        color: AppColors.success,
        size: 16,
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required bool isDark,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final progress = (test.bestScore ?? 0) / 100;
    final color = _getScoreColor(test.bestScore ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Best Score',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 11,
              ),
            ),
            Text(
              '${test.bestScore!.toInt()}% ${test.bestScore! >= 75 ? "✓" : "✗"}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  IconData _getTestTypeIcon(String testType) {
    switch (testType.toLowerCase()) {
      case 'chapter':
        return Icons.book_outlined;
      case 'comprehensive':
        return Icons.quiz_outlined;
      case 'exam':
        return Icons.assignment_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getTestTypeColor(String testType) {
    switch (testType.toLowerCase()) {
      case 'chapter':
        return AppColors.primary;
      case 'comprehensive':
        return AppColors.secondary;
      case 'exam':
        return AppColors.accent;
      default:
        return AppColors.info;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) {
      return AppColors.success;
    }
    if (score >= 75) {
      return AppColors.progressGreen;
    }
    if (score >= 60) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  String _getDisplayTitleWithNumber(Test test, int displayNumber) {
    switch (test.testType.toLowerCase()) {
      case 'chapter':
        return 'Chapter Test $displayNumber';
      case 'comprehensive':
        return 'Comprehensive Test $displayNumber';
      case 'exam':
        return 'Practice Exam $displayNumber';
      default:
        return 'Test $displayNumber';
    }
  }
}