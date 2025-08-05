import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../data/models/Chapter.dart';
import '../../data/models/Test.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/chapter_notifier.dart';
import '../../providers/test_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class ChaptersDetailScreen extends ConsumerStatefulWidget {
  final int chapterId;

  const ChaptersDetailScreen({
    super.key,
    required this.chapterId,
  });

  @override
  ConsumerState<ChaptersDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends ConsumerState<ChaptersDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Chapter? _chapter;
  List<Test> _chapterTests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChapterData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load chapter details
      await ref.read(chapterNotifierProvider.notifier).loadChapterDetails(widget.chapterId);

      // Load chapter tests
      await ref.read(testNotifierProvider.notifier).loadTestsByChapter(widget.chapterId);

      final chapterState = ref.read(chapterNotifierProvider);
      final testState = ref.read(testNotifierProvider);

      setState(() {
        _chapter = chapterState.chapters.firstWhere(
              (chapter) => chapter.id == widget.chapterId,
          orElse: () => throw Exception('Chapter not found'),
        );
        _chapterTests = testState.availableTests['chapter']?.where(
              (test) => test.chapterId == widget.chapterId,
        ).toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chapter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading chapter...'),
      );
    }

    if (_chapter == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Chapter ${widget.chapterId}'),
        body: ErrorDisplayWidget(
          message: 'Chapter not found',
          onRetry: _loadChapterData,

        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chapter ${_chapter!.chapterNumber}',
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: _toggleBookmark,
            tooltip: 'Bookmark Chapter',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareChapter,
            tooltip: 'Share Chapter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadChapterData,
        child: Column(
          children: [
            // Chapter Header
            _buildChapterHeader(),

            // Tab Bar
            _buildTabBar(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTestsTab(),
                  _buildStudyMaterialTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildChapterHeader() {
    final progress = _calculateChapterProgress();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Title
          Text(
            _chapter!.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (_chapter!.description != null) ...[
            const SizedBox(height: 8),
            Text(
              _chapter!.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Progress Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter Progress',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      progressColor: Colors.white,
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircularPercentIndicator(
                radius: 30.0,
                lineWidth: 4.0,
                percent: progress,
                center: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.quiz_outlined,
                label: 'Tests',
                value: '${_chapterTests.length}',
              ),
              _buildStatItem(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: '${_getCompletedTestsCount()}',
              ),
              _buildStatItem(
                icon: Icons.star_outline,
                label: 'Best Score',
                value: '${_getBestScore()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
          Tab(text: 'Tests', icon: Icon(Icons.quiz)),
          Tab(text: 'Study', icon: Icon(Icons.book)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Topics Section
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildKeyTopicsSection(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Learning Objectives
          AnimationConfiguration.staggeredList(
            position: 1,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildLearningObjectivesSection(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Progress Breakdown
          AnimationConfiguration.staggeredList(
            position: 2,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildProgressBreakdownSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTopicsSection() {
    final keyTopics = _getKeyTopicsForChapter(_chapter!.chapterNumber);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.topic_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Topics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...keyTopics.map((topic) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      topic,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningObjectivesSection() {
    final objectives = _getLearningObjectivesForChapter(_chapter!.chapterNumber);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Learning Objectives',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...objectives.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBreakdownSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressItem('Tests Completed', _getCompletedTestsCount(), _chapterTests.length),
            _buildProgressItem('Average Score', _getAverageScore(), 100),
            _buildProgressItem('Time Spent', 45, 60), // Example: 45 minutes out of 60
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, int current, int total) {
    final progress = total > 0 ? current / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$current / $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 6.0,
            percent: progress.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            progressColor: Theme.of(context).colorScheme.primary,
            barRadius: const Radius.circular(3),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTestsTab() {
    if (_chapterTests.isEmpty) {
      return const EmptyState(
        title: 'No Tests Available',
        message: 'Tests for this chapter will be available soon.',
        icon: Icons.quiz_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _chapterTests.length,
      itemBuilder: (context, index) {
        final test = _chapterTests[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: AppConstants.mediumAnimation,
          child: SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(
              child: _buildTestCard(test),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestCard(Test test) {
    final authState = ref.watch(authNotifierProvider);
    final canAccess = authState.canAccessTest(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );
    final bestScore = _getBestScoreForTest(test.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canAccess ? () => _startTest(test) : () => _showAccessDeniedDialog(test),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Test ${test.testNumber}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!canAccess) ...[
                    Icon(
                      test.isFree ? Icons.lock_outline : Icons.diamond,
                      color: test.isFree ? Colors.orange : const Color(AppColors.premiumGold),
                      size: 20,
                    ),
                  ] else if (bestScore != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bestScore >= 75 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$bestScore%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${test.questionCount ?? 24} questions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${AppConstants.testTimeLimit} minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

              if (!canAccess) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.getAccessDeniedReason(
                            isFree: test.isFree,
                            isPremium: test.isPremium,
                          ) ?? 'Access denied',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudyMaterialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Tips
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildStudyTipsSection(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Important Facts
          AnimationConfiguration.staggeredList(
            position: 1,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildImportantFactsSection(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // External Resources
          AnimationConfiguration.staggeredList(
            position: 2,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildExternalResourcesSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTipsSection() {
    final tips = _getStudyTipsForChapter(_chapter!.chapterNumber);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Study Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantFactsSection() {
    final facts = _getImportantFactsForChapter(_chapter!.chapterNumber);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Important Facts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...facts.map((fact) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fact,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalResourcesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'External Resources',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResourceLink(
              'Official UK Government Guide',
              'Read the official Life in the UK handbook',
              Icons.public,
            ),
            _buildResourceLink(
              'Practice Questions',
              'Additional practice questions online',
              Icons.quiz,
            ),
            _buildResourceLink(
              'Video Tutorials',
              'Watch explanatory videos',
              Icons.play_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceLink(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () {
        // TODO: Open external link
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $title...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFloatingActionButton() {
    if (_chapterTests.isEmpty) return const SizedBox.shrink();

    final availableTests = _chapterTests.where((test) {
      final authState = ref.read(authNotifierProvider);
      return authState.canAccessTest(isFree: test.isFree, isPremium: test.isPremium);
    }).toList();

    if (availableTests.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () => _startNextTest(),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Test'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  // Helper Methods
  double _calculateChapterProgress() {
    if (_chapterTests.isEmpty) return 0.0;
    final completedTests = _getCompletedTestsCount();
    return completedTests / _chapterTests.length;
  }

  int _getCompletedTestsCount() {
    // TODO: Implement based on user's test history
    return 0;
  }

  int _getBestScore() {
    // TODO: Implement based on user's test history
    return 0;
  }

  int _getAverageScore() {
    // TODO: Implement based on user's test history
    return 0;
  }

  int? _getBestScoreForTest(int testId) {
    // TODO: Implement based on user's test history
    return null;
  }

  List<String> _getKeyTopicsForChapter(int chapterNumber) {
    switch (chapterNumber) {
      case 1:
        return [
          'British values: democracy, rule of law, individual liberty, mutual respect',
          'Fundamental principles of UK democracy',
          'The importance of participating in community life',
          'Responsibilities and freedoms in the UK',
        ];
      case 2:
        return [
          'Countries of the UK: England, Scotland, Wales, Northern Ireland',
          'Capital cities and major cities',
          'UK population and diversity',
          'Languages spoken in the UK',
        ];
      case 3:
        return [
          'Stone Age to Iron Age Britain',
          'Roman Britain (43-410 AD)',
          'Anglo-Saxons and Vikings',
          'Medieval period and feudalism',
          'Tudor and Stuart dynasties',
          'Industrial Revolution',
          'Two World Wars',
        ];
      case 4:
        return [
          'UK economy and industries',
          'Housing and population',
          'Education system',
          'Healthcare (NHS)',
          'Religion and communities',
          'Sports and leisure',
        ];
      case 5:
        return [
          'The UK system of government',
          'Democracy and elections',
          'The legal system',
          'Your role in the community',
          'Tax and National Insurance',
        ];
      default:
        return ['Key topics for this chapter'];
    }
  }

  List<String> _getLearningObjectivesForChapter(int chapterNumber) {
    switch (chapterNumber) {
      case 1:
        return [
          'Understand the fundamental values that underpin British society',
          'Learn about democracy and the rule of law in the UK',
          'Recognize the importance of individual liberty and mutual respect',
          'Understand your role and responsibilities as a UK resident',
        ];
      default:
        return ['Learn key concepts and facts about this chapter'];
    }
  }

  List<String> _getStudyTipsForChapter(int chapterNumber) {
    return [
      'Read through the material multiple times to reinforce key concepts',
      'Take practice tests regularly to identify areas for improvement',
      'Focus on dates, names, and statistics as these are commonly tested',
      'Use flashcards for memorizing important facts and figures',
      'Join study groups or online forums to discuss difficult topics',
    ];
  }

  List<String> _getImportantFactsForChapter(int chapterNumber) {
    switch (chapterNumber) {
      case 1:
        return [
          'British values include democracy, rule of law, individual liberty, and mutual respect',
          'Everyone in the UK should respect the law and the democratic system',
          'The UK is a parliamentary democracy with a constitutional monarchy',
        ];
      default:
        return ['Important facts will be highlighted here'];
    }
  }

  void _startTest(Test test) {
    context.push('${AppRoutes.testDetail}/${test.id}');
  }

  void _startNextTest() {
    final availableTests = _chapterTests.where((test) {
      final authState = ref.read(authNotifierProvider);
      return authState.canAccessTest(isFree: test.isFree, isPremium: test.isPremium);
    }).toList();

    if (availableTests.isNotEmpty) {
      _startTest(availableTests.first);
    }
  }

  void _showAccessDeniedDialog(Test test) {
    final authState = ref.read(authNotifierProvider);
    final reason = authState.getAccessDeniedReason(
      isFree: test.isFree,
      isPremium: test.isPremium,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: Text(reason ?? 'You cannot access this test.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (test.isPremium)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.premium);
              },
              child: const Text('Upgrade to Premium'),
            ),
        ],
      ),
    );
  }

  void _toggleBookmark() {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark feature coming soon!'),
      ),
    );
  }

  void _shareChapter() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
      ),
    );
  }
}