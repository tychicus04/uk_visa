import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/test_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';

class TestDetailScreen extends ConsumerStatefulWidget {
  const TestDetailScreen({
    required this.testId,
    super.key,
  });

  final int testId;

  @override
  ConsumerState<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends ConsumerState<TestDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final testState = ref.watch(testDetailProvider(widget.testId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.test_details),
      ),
      body: testState.when(
        data: (test) {
          // Determine which tab should be selected based on test type
          final isExamTest = test.testType.toLowerCase() == 'exam';
          if (isExamTest && _tabController.index == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _tabController.animateTo(1);
            });
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPracticeTab(context, test),
              _buildExamTab(context, test),
            ],
          );
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(testDetailProvider(widget.testId)),
        ),
      ),
    );
  }

  Widget _buildPracticeTab(BuildContext context, Test test) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if this test is suitable for practice mode
    final isPracticeTest = test.testType.toLowerCase() == 'chapter' ||
        test.testType.toLowerCase() == 'comprehensive';

    if (!isPracticeTest) {
      return _buildWrongTabMessage(
        context,
        l10n.test_wrongTabExamTitle,
        l10n.test_wrongTabExamMessage,
        Icons.timer,
        AppColors.warning,
      );
    }

    return _buildTestDetails(context, test, false); // false = no timer
  }

  Widget _buildExamTab(BuildContext context, Test test) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if this test is suitable for exam mode
    final isExamTest = test.testType.toLowerCase() == 'exam';

    if (!isExamTest) {
      return _buildWrongTabMessage(
        context,
        l10n.test_wrongTabPracticeTitle,
        l10n.test_wrongTabPracticeMessage,
        Icons.school,
        AppColors.info,
      );
    }

    return _buildTestDetails(context, test, true); // true = with timer
  }

  Widget _buildWrongTabMessage(BuildContext context, String title, String message, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDetails(BuildContext context, Test test, bool hasTimer) {
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
                Row(
                  children: [
                    Icon(
                      hasTimer ? Icons.timer : Icons.school,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        test.title ?? '${l10n.test_test} ${test.testNumber}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasTimer
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasTimer
                          ? AppColors.warning.withOpacity(0.3)
                          : AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    hasTimer ? l10n.test_timedTest : l10n.test_practiceMode,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasTimer ? AppColors.warning : AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasTimer ? l10n.test_examDescription : l10n.test_practiceDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (test.chapterName != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    test.chapterName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats Card
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
                  l10n.test_testInformation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      icon: hasTimer ? Icons.timer : Icons.all_inclusive,
                      label: l10n.duration,
                      value: hasTimer
                          ? l10n.test_timeLimitMinutes(test.effectiveTimeLimit.inMinutes)
                          : l10n.test_unlimited,
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

          // Features Info
          _buildFeaturesInfo(context, test, hasTimer, theme, isDark),

          const SizedBox(height: 24),

          // Progress Card (if has attempts)
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

          // Access Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
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

          // Start Button
          ElevatedButton.icon(
            onPressed: () => _startTest(context, hasTimer),
            icon: Icon(hasTimer ? Icons.timer : Icons.school),
            label: Text(
                hasTimer ? l10n.test_startTimedTest : l10n.test_startPractice
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasTimer ? AppColors.warning : AppColors.info,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesInfo(BuildContext context, Test test, bool hasTimer, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasTimer
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTimer
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasTimer ? Icons.warning_amber_outlined : Icons.info_outline,
                color: hasTimer ? AppColors.warning : AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasTimer ? l10n.test_timedTestFeatures : l10n.test_practiceTestFeatures,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasTimer ? AppColors.warning : AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasTimer) ...[
            _buildFeatureItem(l10n.test_timeLimitMinutes(test.effectiveTimeLimit.inMinutes), Icons.timer),
            _buildFeatureItem(l10n.test_autoSubmitWhenExpires, Icons.send),
            _buildFeatureItem(l10n.test_realExamSimulation, Icons.assignment_turned_in),
          ] else ...[
            _buildFeatureItem(l10n.test_noTimePressure, Icons.schedule),
            _buildFeatureItem(l10n.test_reviewAnswersImmediate, Icons.visibility),
            _buildFeatureItem(l10n.test_focusLearning, Icons.lightbulb_outline),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );

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

  Future<void> _startTest(BuildContext context, bool hasTimer) async {
    final l10n = AppLocalizations.of(context);

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

      final attemptId = await ref.read(testProvider.notifier).startAttempt(widget.testId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.go('/test-taking/${widget.testId}?attemptId=$attemptId');
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
              onPressed: () => _startTest(context, hasTimer),
            ),
          ),
        );
      }
    }
  }
}