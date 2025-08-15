import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../widgets/test_card.dart';

class TestListScreen extends ConsumerStatefulWidget {
  const TestListScreen({super.key});

  @override
  ConsumerState<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends ConsumerState<TestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed from 3 to 2
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final testsState = ref.watch(availableTestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigation_tests),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Practice', // Combined practice tests
              icon: const Icon(Icons.quiz_outlined),
            ),
            Tab(
              text: 'Exam', // Real exam simulation
              icon: const Icon(Icons.assignment_outlined),
            ),
          ],
        ),
      ),
      body: testsState.when(
        data: (tests) {
          // Combine chapter and comprehensive tests for Practice tab
          final practiceTests = [
            ...(tests['chapter'] ?? []),
            ...(tests['comprehensive'] ?? []),
          ];

          final examTests = tests['exam'] ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTestList(
                practiceTests,
                emptyMessage: 'No practice tests available',
                showTestType: true, // Show test type badges since we're mixing types
              ),
              _buildTestList(
                examTests,
                emptyMessage: 'No exam tests available',
                showTestType: false, // All are exam type, no need to show
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

  Widget _buildTestList(
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

    // Sort tests for better organization
    final sortedTests = List.from(tests)..sort((a, b) {
      // First sort by test type (chapter first, then comprehensive, then exam)
      final typeOrder = {'chapter': 0, 'comprehensive': 1, 'exam': 2};
      final aOrder = typeOrder[a.testType] ?? 3;
      final bOrder = typeOrder[b.testType] ?? 3;

      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }

      // Then sort by chapter if available
      if (a.chapterId != null && b.chapterId != null) {
        final chapterCompare = a.chapterIdInt.compareTo(b.chapterIdInt);
        if (chapterCompare != 0) return chapterCompare;
      }

      // Finally sort by test number
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
              context.go('/tests/${test.id}');
            },
          ),
        );
      },
    );
  }
}