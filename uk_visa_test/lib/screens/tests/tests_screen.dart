import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/test_notifier.dart';
import '../../data/models/Test.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_app_bar.dart';

class TestsScreen extends ConsumerStatefulWidget {
  const TestsScreen({super.key});

  @override
  ConsumerState<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends ConsumerState<TestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testNotifierProvider.notifier).loadAvailableTests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.tests,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Premium Banner (if not premium)
          if (!authState.isPremium) _buildPremiumBanner(context),

          // Tab Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(text: l10n.chapterTests),
                Tab(text: l10n.comprehensiveTests),
                Tab(text: l10n.examTests),
              ],
            ),
          ),

          // Content
          Expanded(
            child: testState.isLoading
                ? LoadingWidget(message: l10n.loading)
                : testState.error != null
                ? ErrorDisplayWidget(
              message: testState.error!,
              onRetry: () => ref.read(testNotifierProvider.notifier).loadAvailableTests(),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                _buildTestsList('chapter', testState.availableTests['chapter'] ?? []),
                _buildTestsList('comprehensive', testState.availableTests['comprehensive'] ?? []),
                _buildTestsList('exam', testState.availableTests['exam'] ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final remainingTests = authState.remainingFreeTests;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(AppColors.premiumGradientStart),
            Color(AppColors.premiumGradientEnd),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.diamond,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remainingTests > 0
                      ? l10n.freeTestsRemaining(remainingTests)
                      : l10n.freeTestsUsed,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  l10n.upgradeToPremium,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.premium),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(AppColors.premiumGold),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(l10n.upgradeNow),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList(String category, List<Test> tests) {
    final filteredTests = _filterTests(tests);
    final l10n = AppLocalizations.of(context)!;

    if (filteredTests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTestsAvailable,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(testNotifierProvider.notifier).loadAvailableTests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: filteredTests.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: TestCard(
                  test: filteredTests[index],
                  onTap: () => _navigateToTestDetail(filteredTests[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Test> _filterTests(List<Test> tests) {
    if (_searchQuery.isEmpty) return tests;

    return tests.where((test) {
      return test.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          test.testNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (test.chapterName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _navigateToTestDetail(Test test) {
    context.push(AppRoutes.testDetailPath(test.id));
  }

  void _showSearchDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.searchTests),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchTests,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              Navigator.of(context).pop();
            },
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class TestCard extends ConsumerWidget {
  final Test test;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.test,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final canAccess = authState.canAccessTest(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );
    final accessDeniedReason = authState.getAccessDeniedReason(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: canAccess ? onTap : () => _showAccessDeniedDialog(context, accessDeniedReason),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Test Icon
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

                  // Test Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              test.testNumber,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (test.isPremium && !test.isFree)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(AppColors.premiumGold),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PREMIUM',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          test.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (test.chapterName != null)
                          Text(
                            test.chapterName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Access Status
                  if (!canAccess)
                    Icon(
                      Icons.lock_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      size: 20,
                    )
                  else if (test.hasAttempts)
                    Icon(
                      test.isPassed ? Icons.check_circle : Icons.history,
                      color: test.isPassed ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Test Stats
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.quiz_outlined,
                    '${test.questionCount} questions',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.access_time,
                    '45 min',
                  ),
                  if (test.hasAttempts) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      context,
                      Icons.repeat,
                      '${test.attemptCount} attempts',
                    ),
                  ],
                ],
              ),

              if (test.hasAttempts) ...[
                const SizedBox(height: 12),

                // Best Score
                Row(
                  children: [
                    Text(
                      'Best Score: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      test.formattedBestScore,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: test.isPassed ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (test.isPassed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PASSED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
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

  IconData _getTestTypeIcon(String testType) {
    switch (testType) {
      case 'chapter':
        return Icons.book_outlined;
      case 'comprehensive':
        return Icons.library_books_outlined;
      case 'exam':
        return Icons.assignment_outlined;
      default:
        return Icons.quiz_outlined;
    }
  }

  void _showAccessDeniedDialog(BuildContext context, String? reason) {
    if (reason == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Restricted'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (reason.contains('premium'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.premium);
              },
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }
}