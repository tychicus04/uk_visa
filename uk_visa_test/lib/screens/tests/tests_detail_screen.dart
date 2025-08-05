import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/AuthState.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/test_notifier.dart';
import '../../data/models/Test.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_button.dart';

class TestDetailScreen extends ConsumerStatefulWidget {
  final int testId;

  const TestDetailScreen({
    super.key,
    required this.testId,
  });

  @override
  ConsumerState<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends ConsumerState<TestDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testNotifierProvider.notifier).loadTestDetails(widget.testId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final test = testState.currentTest;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: test?.testNumber ?? 'Test',
        actions: [
          if (test != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareTest(test),
            ),
        ],
      ),
      body: testState.isLoading
          ? LoadingWidget(message: l10n.loading)
          : testState.error != null
          ? ErrorDisplayWidget(
        message: testState.error!,
        onRetry: () => ref.read(testNotifierProvider.notifier).loadTestDetails(widget.testId),
      )
          : test == null
          ? const ErrorDisplayWidget(message: 'Test not found')
          : _buildTestDetails(test, authState),
      bottomNavigationBar: test != null ? _buildBottomBar(test, authState) : null,
    );
  }

  Widget _buildTestDetails(Test test, AuthState authState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Test Header
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildTestHeader(test),
              ),
            ),
          ),

          // Test Info Cards
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Basic Info Card
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: _buildBasicInfoCard(test),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Progress Card (if has attempts)
                if (test.hasAttempts) ...[
                  AnimationConfiguration.staggeredList(
                    position: 2,
                    duration: AppConstants.mediumAnimation,
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: _buildProgressCard(test),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instructions Card
                AnimationConfiguration.staggeredList(
                  position: 3,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: _buildInstructionsCard(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Requirements Card
                AnimationConfiguration.staggeredList(
                  position: 4,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: _buildRequirementsCard(test, authState),
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestHeader(Test test) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTestTypeColor(test.testType),
            _getTestTypeColor(test.testType).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getTestTypeLabel(test.testType),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Test Title
          Text(
            test.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (test.chapterName != null) ...[
            const SizedBox(height: 4),
            Text(
              test.chapterName!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              _buildHeaderStat(Icons.quiz_outlined, '${test.questionCount}', 'Questions'),
              const SizedBox(width: 24),
              _buildHeaderStat(Icons.access_time, '45', 'Minutes'),
              const SizedBox(width: 24),
              _buildHeaderStat(Icons.school_outlined, '75%', 'To Pass'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(Test test) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(Icons.numbers, 'Test Number', test.testNumber),
            _buildInfoRow(Icons.quiz, 'Questions', '${test.questionCount}'),
            _buildInfoRow(Icons.timer, 'Time Limit', '45 minutes'),
            _buildInfoRow(Icons.school, 'Passing Score', '75%'),
            if (test.isFree)
              _buildInfoRow(Icons.free_breakfast, 'Access', 'Free')
            else if (test.isPremium)
              _buildInfoRow(Icons.diamond, 'Access', 'Premium Only'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Test test) {
    final passRate = test.isPassed ? 100.0 : 0.0;
    final bestScore = test.bestScore ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Progress Circle
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 6.0,
                  percent: (bestScore / 100).clamp(0.0, 1.0),
                  center: Text(
                    '${bestScore.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  progressColor: bestScore >= 75 ? Colors.green : Colors.orange,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),

                const SizedBox(width: 24),

                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressStat('Best Score', test.formattedBestScore),
                      _buildProgressStat('Attempts', '${test.attemptCount}'),
                      _buildProgressStat('Status', test.isPassed ? 'PASSED' : 'NEEDS IMPROVEMENT'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildInstructionItem('Read each question carefully'),
            _buildInstructionItem('Select the best answer(s)'),
            _buildInstructionItem('You can review and change answers'),
            _buildInstructionItem('Submit when you\'re confident'),
            _buildInstructionItem('You need 75% to pass'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard(Test test, AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    final canAccess = authState.canAccessTest(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canAccess ? Icons.check_circle : Icons.lock_outline,
                  color: canAccess ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Requirements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (test.isFree) ...[
              _buildRequirementItem(
                'Free test access',
                authState.remainingFreeTests > 0 || authState.isPremium,
                authState.remainingFreeTests > 0 || authState.isPremium
                    ? 'Available'
                    : 'No free tests remaining',
              ),
            ],

            if (test.isPremium && !test.isFree) ...[
              _buildRequirementItem(
                'Premium subscription',
                authState.isPremium,
                authState.isPremium ? 'Active' : 'Required',
              ),
            ],

            _buildRequirementItem(
              'Internet connection',
              true, // Assume connected if they can see this screen
              'Required for submission',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String title, bool isMet, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isMet ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Test test, AuthState authState) {
    final canAccess = authState.canAccessTest(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );
    final accessDeniedReason = authState.getAccessDeniedReason(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (test.hasAttempts)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Show test history
                  },
                  child: const Text('View History'),
                ),
              ),

            if (test.hasAttempts) const SizedBox(width: 12),

            Expanded(
              flex: test.hasAttempts ? 2 : 1,
              child: LoadingButton(
                onPressed: canAccess ? () => _startTest(test) : () => _showAccessDenied(accessDeniedReason),
                isLoading: ref.watch(testNotifierProvider).isLoading,
                text: test.hasAttempts ? l10n.retakeTest : l10n.startTest,
                icon: canAccess ? Icons.play_arrow : Icons.lock,
                backgroundColor: canAccess ? null : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTest(Test test) async {
    final success = await ref.read(testNotifierProvider.notifier).startTest(test.id);

    if (success && mounted) {
      context.push(AppRoutes.testTakingPath(test.id));
    }
  }

  void _showAccessDenied(String? reason) {
    if (reason == null) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Restricted'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
          if (reason.contains('premium'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.premium);
              },
              child: Text(l10n.upgradeNow),
            ),
        ],
      ),
    );
  }

  void _shareTest(Test test) {
    // TODO: Implement test sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${test.title}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Color _getTestTypeColor(String testType) {
    switch (testType) {
      case 'chapter':
        return const Color(AppColors.primaryColor);
      case 'comprehensive':
        return const Color(AppColors.secondaryColor);
      case 'exam':
        return const Color(AppColors.accentColor);
      default:
        return const Color(AppColors.primaryColor);
    }
  }

  String _getTestTypeLabel(String testType) {
    switch (testType) {
      case 'chapter':
        return 'CHAPTER TEST';
      case 'comprehensive':
        return 'COMPREHENSIVE';
      case 'exam':
        return 'PRACTICE EXAM';
      default:
        return 'TEST';
    }
  }
}