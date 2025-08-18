import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/test_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';

class TestDetailScreen extends ConsumerWidget {

  const TestDetailScreen({
    required this.testId,
    super.key,
  });
  final int testId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final testState = ref.watch(testDetailProvider(testId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.test_details),
      ),
      body: testState.when(
        data: (test) => _buildTestDetails(context, test, ref),
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(testDetailProvider(testId)),
        ),
      ),
    );
  }

  Widget _buildTestDetails(BuildContext context, Test test, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                Text(
                  test.title ?? 'Test ${test.testNumber}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (test.chapterName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    test.chapterName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.quiz,
                      label: l10n.questions,
                      value: '${test.questionCount ?? 24}',
                      theme: theme,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.timer,
                      label: l10n.duration,
                      value: '45 ${l10n.minutes}',
                      theme: theme,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.trending_up,
                      label: l10n.pass_rate,
                      value: '75%',
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (test.attemptCount != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.your_progress,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressItem(
                          label: l10n.attempts,
                          value: '${test.attemptCount}',
                          theme: theme,
                        ),
                      ),
                      if (test.bestScore != null)
                        Expanded(
                          child: _buildProgressItem(
                            label: l10n.best_score,
                            value: '${test.bestScore?.toInt()}%',
                            theme: theme,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                  color: AppColors.success
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.you_can_access_this_test,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _startTest(context, ref),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.test_startTest),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) => Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );

  Widget _buildProgressItem({
    required String label,
    required String value,
    required ThemeData theme,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );

  Future<void> _startTest(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.test_startingTest),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 10),
        ),
      );

      final attemptId = await ref.read(testProvider.notifier).startAttempt(testId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.go('/test-taking/$testId?attemptId=$attemptId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.test_testStartError),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: l10n.common_retry,
              textColor: Colors.white,
              onPressed: () => _startTest(context, ref),
            ),
          ),
        );
      }
    }
  }
}

