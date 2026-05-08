import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/interstitial_ad_service.dart';
import '../../../core/services/purchase_service.dart';
import '../../../data/models/test_model.dart';
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
  final InterstitialAdService _interstitialAdService = InterstitialAdService();
  bool _initialTabSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load interstitial ad for when starting test (will check purchase status)
    _loadAdWithPurchaseCheck();
  }

  void _loadAdWithPurchaseCheck() {
    // Check if user has purchased ad removal
    final shouldShowAds = ref.read(shouldShowAdsProvider);
    _interstitialAdService.setShouldShowAds(shouldShowAds);
    
    _interstitialAdService.loadAd(
      onAdLoaded: () {
        print('🎯 Interstitial ad ready for test start');
      },
      onAdFailedToLoad: (error) {
        print('⚠️ Failed to load interstitial ad: $error');
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interstitialAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testDetailProvider(widget.testId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Details'),
      ),
      body: testState.when(
        data: (test) {
          // One-time tab selection based on test type. Done once per session so
          // the user can still switch tabs manually after the initial load.
          if (!_initialTabSelected) {
            _initialTabSelected = true;
            final defaultTabIndex = test.isTimed ? 1 : 0;
            if (_tabController.index != defaultTabIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _tabController.animateTo(defaultTabIndex);
                }
              });
            }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Practice mode is reserved for chapter tests only.
    final isPracticeTest = test.testType.toLowerCase() == 'chapter';

    if (!isPracticeTest) {
      return _buildWrongTabMessage(
        context,
        'This is a timed test',
        'This test is designed for timed exam mode. Please switch to the Exam tab.',
        Icons.timer,
        AppColors.warning,
      );
    }

    return _buildTestDetails(context, test, false); // false = no timer
  }

  Widget _buildExamTab(BuildContext context, Test test) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Exam tab covers both `exam` and `comprehensive` (both are timed in TestTakingScreen).
    if (!test.isTimed) {
      return _buildWrongTabMessage(
        context,
        'This is a practice test',
        'This test is designed for practice mode. Please switch to the Practice tab.',
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
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
                        test.title ?? 'Test ${test.testNumber}',
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
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasTimer
                          ? AppColors.warning.withValues(alpha: 0.3)
                          : AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    hasTimer ? 'Timed Test' : 'Practice Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasTimer ? AppColors.warning : AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasTimer ? 'Complete this timed test under exam conditions' : 'Practice at your own pace without time pressure',
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
                  'Test Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
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
                      icon: hasTimer ? Icons.timer : Icons.all_inclusive,
                      label: 'Duration',
                      value: hasTimer
                          ? '${test.effectiveTimeLimit.inMinutes} minutes'
                          : 'Unlimited',
                      theme: theme,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.trending_up,
                      label: 'Pass Rate',
                      value: '${AppConstants.passingScorePercent.toInt()}%',
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
              color: AppColors.success.withValues(alpha: 0.1),
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
                    'You can access this test',
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
                hasTimer ? 'Start Timed Test' : 'Start Practice'
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasTimer
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTimer
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.info.withValues(alpha: 0.3),
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
                hasTimer ? 'Timed Test Features' : 'Practice Test Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasTimer ? AppColors.warning : AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasTimer) ...[
            _buildFeatureItem('${test.effectiveTimeLimit.inMinutes} minutes time limit', Icons.timer),
            _buildFeatureItem('Auto-submit when time expires', Icons.send),
            _buildFeatureItem('Real exam simulation', Icons.assignment_turned_in),
          ] else ...[
            _buildFeatureItem('No time pressure', Icons.schedule),
            _buildFeatureItem('Review answers immediately', Icons.visibility),
            _buildFeatureItem('Focus on learning', Icons.lightbulb_outline),
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
    // Show interstitial ad before starting test
    await _interstitialAdService.showAd(
      onAdDismissed: () async {
        // Ad was dismissed, proceed with starting test
        await _startTestAfterAd(context);
      },
      onAdFailedToShow: () async {
        // Ad failed to show, proceed with starting test anyway
        await _startTestAfterAd(context);
      },
    );
  }

  Future<void> _startTestAfterAd(BuildContext context) async {
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
              const Text('Starting test...'),
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
            content: const Text('Failed to start test. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Reload ad for retry
                _interstitialAdService.loadAd(
                  onAdLoaded: () => print('🎯 Ad reloaded for retry'),
                  onAdFailedToLoad: (error) => print('⚠️ Failed to reload ad: $error'),
                );
                _startTest(context, false);
              },
            ),
          ),
        );
      }
    }
  }
}