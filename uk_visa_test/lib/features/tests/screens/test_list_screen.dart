import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../widgets/test_card.dart';

class TestListScreen extends ConsumerStatefulWidget {
  final int initialTab;
  
  const TestListScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends ConsumerState<TestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1), // Ensure valid tab index
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final testsState = ref.watch(availableTestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigation_tests),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: l10n.test_practice, // ✅ Localized
              icon: const Icon(Icons.quiz_outlined),
            ),
            Tab(
              text: l10n.test_exam, // ✅ Localized
              icon: const Icon(Icons.assignment_outlined),
            ),
          ],
        ),
      ),
      body: testsState.when(
        data: (tests) {
          // 🔄 UPDATED: Practice tab only shows chapter tests
          final practiceTests = tests['chapter'] ?? [];

          // 🔄 UPDATED: Exam tab shows comprehensive + exam tests
          final examTests = [
            ...(tests['comprehensive'] ?? []),
            ...(tests['exam'] ?? []),
          ];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPracticeTestsByChapter(
                l10n,
                practiceTests,
                emptyMessage: l10n.test_noPracticeTests,
              ),
              _buildTestList(
                l10n,
                examTests,
                emptyMessage: l10n.test_noExamTests,
                showTestType: true, // Show type since we have both comprehensive and exam
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(availableTestsProvider),
        ),
      ),
    );
  }

  // Group practice tests by chapter with expandable sections
  Widget _buildPracticeTestsByChapter(
    AppLocalizations l10n,
    List<dynamic> tests, {
    required String emptyMessage,
  }) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // Group tests by chapter
    final Map<String, List<dynamic>> testsByChapter = {};
    for (var test in tests) {
      final chapterId = test.chapterId ?? 'unknown';
      if (!testsByChapter.containsKey(chapterId)) {
        testsByChapter[chapterId] = [];
      }
      testsByChapter[chapterId]!.add(test);
    }

    // Sort chapters by ID
    final sortedChapterIds = testsByChapter.keys.toList()
      ..sort((a, b) {
        if (a == 'unknown') return 1;
        if (b == 'unknown') return -1;
        return int.tryParse(a)?.compareTo(int.tryParse(b) ?? 0) ?? 0;
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedChapterIds.length,
      itemBuilder: (context, index) {
        final chapterId = sortedChapterIds[index];
        final chapterTests = testsByChapter[chapterId]!;
        
        // Sort tests within chapter by test number
        chapterTests.sort((a, b) => a.testNumber.compareTo(b.testNumber));
        
        final chapterName = chapterTests.first.chapterName ?? 'Chapter $chapterId';
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                childrenPadding: const EdgeInsets.only(bottom: 12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      chapterId == 'unknown' ? '?' : chapterId,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  chapterName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                subtitle: Text(
                  '${chapterTests.length} ${chapterTests.length == 1 ? 'test' : 'tests'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                children: chapterTests.map((test) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TestCard(
                      test: test,
                      showTestType: false,
                      onTap: () {
                        context.go('/tests/detail/${test.id}');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestList(
      AppLocalizations l10n,
      List<dynamic> tests, {
        required String emptyMessage,
        bool showTestType = false,
      }) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    final sortedTests = List.from(tests)..sort((a, b) {
      final typeOrder = {'chapter': 0, 'comprehensive': 1, 'exam': 2};
      final aOrder = typeOrder[a.testType] ?? 3;
      final bOrder = typeOrder[b.testType] ?? 3;

      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }

      if (a.chapterId != null && b.chapterId != null) {
        final chapterCompare = a.chapterIdInt.compareTo(b.chapterIdInt);
        if (chapterCompare != 0) {
          return chapterCompare;
        }
      }

      return a.testNumber.compareTo(b.testNumber);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTests.length,
      itemBuilder: (context, index) {
        final test = sortedTests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TestCard(
            test: test,
            showTestType: showTestType,
            onTap: () {
              context.go('/tests/detail/${test.id}');
            },
          ),
        );
      },
    );
  }
}