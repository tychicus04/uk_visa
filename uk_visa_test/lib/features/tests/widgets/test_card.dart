import 'package:flutter/material.dart';
import '../../../data/models/test_model.dart';
import '../../../app/theme/app_colors.dart';

class TestCard extends StatelessWidget {
  final Test test;
  final VoidCallback onTap;
  final bool showTestType;

  const TestCard({
    super.key,
    required this.test,
    required this.onTap,
    this.showTestType = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with test info and status
              Row(
                children: [
                  // Test icon based on type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTestTypeColor(test.testType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTestTypeIcon(test.testType),
                      color: _getTestTypeColor(test.testType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Test title and number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.displayTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (showTestType) ...[
                              _buildTestTypeBadge(context),
                            ],
                            if (test.chapterName != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  test.chapterName!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
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

                  // Access indicator
                  _buildAccessIndicator(context),
                ],
              ),

              const SizedBox(height: 12),

              // Test stats row
              Row(
                children: [
                  // Question count
                  _buildStatChip(
                    context,
                    icon: Icons.quiz_outlined,
                    label: '${test.questionCountInt} questions',
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),

                  // Attempts count
                  if (test.attemptCountInt > 0) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.history,
                      label: '${test.attemptCountInt} attempts',
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Best score
                  if (test.bestScore != null) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.star_outlined,
                      label: '${test.bestScore!.toInt()}%',
                      color: _getScoreColor(test.bestScore!),
                    ),
                  ],

                  const Spacer(),


                    _buildStatChip(
                      context,
                      icon: Icons.free_breakfast,
                      label: 'Free',
                      color: AppColors.success,
                    )

                ],
              ),

              // Progress indicator if there are attempts
              if (test.attemptCountInt > 0 && test.bestScore != null) ...[
                const SizedBox(height: 12),
                _buildProgressIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestTypeBadge(BuildContext context) {
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
        color: _getTestTypeColor(test.testType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getTestTypeColor(test.testType).withOpacity(0.3),
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

  Widget _buildAccessIndicator(BuildContext context) {
    final theme = Theme.of(context);

    if (!test.isAccessible) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.lock_outline,
          color: AppColors.error,
          size: 16,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
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
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildProgressIndicator(BuildContext context) {
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
                color: theme.colorScheme.outline,
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
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 3,
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
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.progressGreen;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}