// lib/features/tests/widgets/test_card.dart
import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../app/theme/app_colors.dart';

class TestCard extends StatelessWidget {
  final dynamic test;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.test,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Test Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTestTypeColor(test.testType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    test.testNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTestTypeColor(test.testType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Access Status
                Icon(
                  test.canAccess == true ? Icons.play_circle : Icons.lock,
                  color: test.canAccess == true
                      ? AppColors.success
                      : AppColors.warning,
                  size: 20,
                ),
                if (!test.isFree) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 16,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              test.title ?? 'Test ${test.testNumber}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Chapter Name
            if (test.chapterName != null) ...[
              const SizedBox(height: 4),
              Text(
                test.chapterName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.quiz,
                  label: '${test.questionCount ?? 24} questions',
                  theme: theme,
                ),
                const SizedBox(width: 12),
                if (test.attemptCount != null)
                  _buildStatChip(
                    icon: Icons.history,
                    label: '${test.attemptCount} attempts',
                    theme: theme,
                  ),
              ],
            ),

            // Best Score
            if (test.bestScore != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Best: ${test.bestScore?.toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTestTypeColor(String testType) {
    switch (testType) {
      case 'chapter':
        return AppColors.primary;
      case 'comprehensive':
        return AppColors.secondary;
      case 'exam':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }
}



