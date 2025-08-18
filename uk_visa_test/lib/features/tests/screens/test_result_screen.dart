import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final resultState = ref.watch(attemptDetailProvider(attemptId));

    return resultState.when(
      data: (result) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.test_testResults),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/'),
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
                      result.isPassed ? l10n.test_passed : l10n.test_failed,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.score}: ${result.percentage?.toStringAsFixed(1) ?? '0'}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.test_passingScore,
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
                      label: l10n.test_correct,
                      value: '${result.score}',
                      total: '${result.totalQuestions}',
                      color: AppColors.success,
                      theme: theme,
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScoreCard(
                      icon: Icons.access_time,
                      label: l10n.test_timeTakenLabel,
                      value: _formatTime(result.timeTakenInt),
                      total: '45 ${l10n.minutes}',
                      color: AppColors.primary,
                      theme: theme,
                      l10n: l10n,
                    ),
                  ),
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
                label: Text(l10n.test_reviewAnswers),
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
                label: Text(l10n.test_retakeTest),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: Text(l10n.test_backToHome),
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
                        l10n.test_testInformation,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        l10n.test_test,
                        result.title ?? l10n.common_unknown,
                        l10n,
                      ),
                      if (result.testNumber != null)
                        _buildInfoRow(
                          context,
                          l10n.test_testNumber,
                          result.testNumber!,
                          l10n,
                        ),
                      if (result.chapterName != null)
                        _buildInfoRow(
                          context,
                          l10n.chapter,
                          result.chapterName!,
                          l10n,
                        ),
                      _buildInfoRow(
                        context,
                        l10n.test_completedAt,
                        _formatDate(result.completedAt, l10n),
                        l10n,
                      ),
                      if (result.timeTakenInt > 0)
                        _buildInfoRow(
                          context,
                          l10n.duration,
                          _formatTime(result.timeTakenInt),
                          l10n,
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
    required AppLocalizations l10n,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '${l10n.common_of} $total',
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
      AppLocalizations l10n,
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatDate(String? dateString, AppLocalizations l10n) {
    if (dateString == null) return l10n.common_unknown;

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}