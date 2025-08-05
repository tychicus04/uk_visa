import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/User.dart';
import '../../providers/TestState.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/test_notifier.dart';
import '../../providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(testNotifierProvider.notifier).loadAvailableTests(),
      ref.read(userNotifierProvider.notifier).loadRecentAttempts(limit: 5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final testState = ref.watch(testNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(AppColors.primaryColor),
                        Color(AppColors.primaryDark),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            user.fullName ?? user.email.split('@')[0],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick Stats Card
                  _buildQuickStatsCard(user),

                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildSectionHeader(context, 'Recent Activity', () {
                    context.push(AppRoutes.history);
                  }),

                  const SizedBox(height: 12),

                  _buildRecentActivity(),

                  const SizedBox(height: 24),

                  // Recommended Tests
                  _buildSectionHeader(context, 'Recommended Tests', () {
                    context.push(AppRoutes.tests);
                  }),

                  const SizedBox(height: 12),

                  _buildRecommendedTests(testState),

                  const SizedBox(height: 24),

                  // Study Progress
                  _buildStudyProgress(user),

                  const SizedBox(height: 100), // Bottom padding for nav bar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(User user) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: AppConstants.mediumAnimation,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  if (!user.hasActiveSubscription) ...[
                    // Free Tests Remaining
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.quiz_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Free Tests Remaining',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${user.remainingFreeTests} of ${user.freeTestsLimit}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user.remainingFreeTests == 0)
                          TextButton(
                            onPressed: () => context.push(AppRoutes.premium),
                            child: const Text('Upgrade'),
                          ),
                      ],
                    ),

                    const Divider(height: 24),
                  ],

                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        context,
                        'Tests Taken',
                        '${user.stats?.totalAttempts ?? 0}',
                        Icons.assignment_outlined,
                      ),
                      _buildStatItem(
                        context,
                        'Best Score',
                        '${user.stats?.bestScore.toStringAsFixed(1) ?? '0'}%',
                        Icons.star_outline,
                      ),
                      _buildStatItem(
                        context,
                        'Pass Rate',
                        '${user.stats?.passRate.toStringAsFixed(0) ?? '0'}%',
                        Icons.trending_up_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: AppConstants.mediumAnimation,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'Take Test',
                  'Start practicing',
                  Icons.play_circle_outline,
                  const Color(AppColors.primaryColor),
                      () => context.push(AppRoutes.tests),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'Study Chapters',
                  'Review materials',
                  Icons.book_outlined,
                  const Color(AppColors.secondaryColor),
                      () => context.push(AppRoutes.chapters),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final userState = ref.watch(userNotifierProvider);

    if (userState.isLoading) {
      return const SizedBox(
        height: 100,
        child: LoadingWidget(message: 'Loading recent activity...'),
      );
    }

    if (userState.recentAttempts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No recent activity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: userState.recentAttempts.take(3).map((attempt) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: attempt.isPassed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                attempt.isPassed ? Icons.check : Icons.close,
                color: attempt.isPassed ? Colors.green : Colors.red,
              ),
            ),
            title: Text(attempt.testTitle ?? 'Test'),
            subtitle: Text(
              '${attempt.formattedScore} - ${attempt.formattedPercentage}',
            ),
            trailing: Text(
              attempt.completedAt != null
                  ? _formatDate(attempt.completedAt!)
                  : 'In Progress',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              context.push(AppRoutes.attemptDetailPath(attempt.id));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedTests(TestState testState) {
    if (testState.isLoading) {
      return const SizedBox(
        height: 100,
        child: LoadingWidget(message: 'Loading tests...'),
      );
    }

    final freeTests = testState.availableTests['chapter'] ?? [];
    final recommendedTests = freeTests.take(3).toList();

    if (recommendedTests.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.largePadding),
          child: Center(
            child: Text('No tests available'),
          ),
        ),
      );
    }

    return Column(
      children: recommendedTests.map((test) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.quiz,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(test.title),
            subtitle: Text('${test.questionCount} questions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push(AppRoutes.testDetailPath(test.id));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudyProgress(User user) {
    final stats = user.stats;
    if (stats == null) return const SizedBox.shrink();

    return AnimationConfiguration.staggeredList(
      position: 4,
      duration: AppConstants.mediumAnimation,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress Ring
                  Center(
                    child: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 8.0,
                      percent: (stats.averageScore / 100).clamp(0.0, 1.0),
                      center: Text(
                        '${stats.averageScore.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      progressColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Average Score',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (stats.averageScore < 75) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Keep practicing to reach the passing score of 75%!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}