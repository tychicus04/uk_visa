// lib/features/tests/screens/test_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/test_card.dart';
import '../providers/test_provider.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: l10n.test_chapterTests),
            Tab(text: l10n.test_comprehensiveTests),
            Tab(text: l10n.test_practiceExams),
          ],
        ),
      ),
      body: testsState.when(
        data: (tests) => TabBarView(
          controller: _tabController,
          children: [
            _buildTestList(tests['chapter'] ?? []),
            _buildTestList(tests['comprehensive'] ?? []),
            _buildTestList(tests['exam'] ?? []),
          ],
        ),
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(availableTestsProvider),
        ),
      ),
    );
  }

  Widget _buildTestList(List<dynamic> tests) {
    if (tests.isEmpty) {
      return const Center(
        child: Text('No tests available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TestCard(
            test: test,
            onTap: () {
              context.go('/tests/${test.id}');
            },
          ),
        );
      },
    );
  }
}


