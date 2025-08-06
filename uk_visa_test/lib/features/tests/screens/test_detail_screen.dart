// lib/features/tests/screens/test_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';

class TestDetailScreen extends ConsumerWidget {
  final int testId;

  const TestDetailScreen({
    super.key,
    required this.testId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final testState = ref.watch(testDetailProvider(testId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Test Details'),
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

  Widget _buildTestDetails(BuildContext context, dynamic test, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Test Info Card
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
                    test.chapterName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Test Stats
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.quiz,
                      label: 'Questions',
                      value: '${test.questionCount ?? 24}',
                      theme: theme,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: '45 min',
                      theme: theme,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.trending_up,
                      label: 'Pass Rate',
                      value: '75%',
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Previous Attempts
          if (test.attemptCount != null && test.attemptCount > 0) ...[
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
                    'Your Progress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressItem(
                          label: 'Attempts',
                          value: '${test.attemptCount}',
                          theme: theme,
                        ),
                      ),
                      if (test.bestScore != null)
                        Expanded(
                          child: _buildProgressItem(
                            label: 'Best Score',
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

          // Access Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: test.canAccess == true
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: test.canAccess == true
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  test.canAccess == true
                      ? Icons.check_circle
                      : Icons.lock,
                  color: test.canAccess == true
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    test.canAccess == true
                        ? 'You can access this test'
                        : test.isPremium
                        ? 'Premium subscription required'
                        : 'Free test limit reached',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: test.canAccess == true
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          if (test.canAccess == true) ...[
            ElevatedButton.icon(
              onPressed: () => _startTest(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.test_startTest),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (test.attemptCount != null && test.attemptCount > 0) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/progress');
                },
                icon: const Icon(Icons.history),
                label: Text(l10n.test_viewResults),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to subscription
                context.go('/subscription');
              },
              icon: const Icon(Icons.upgrade),
              label: Text(l10n.subscription_upgrade),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
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
  }

  Widget _buildProgressItem({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
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
  }

  Future<void> _startTest(BuildContext context, WidgetRef ref) async {
    try {
      // Start test attempt
      final attemptId = await ref.read(testProvider.notifier).startAttempt(testId);
      if (context.mounted) {
        // FIXED: Navigation to test taking screen
        context.go('/tests/$testId/take?attemptId=$attemptId');
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

