import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/Chapter.dart';
import '../../providers/app_providers.dart';
import '../../providers/chapter_notifier.dart';
import '../../data/models/Test.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_app_bar.dart';

class ChaptersScreen extends ConsumerStatefulWidget {
  const ChaptersScreen({super.key});

  @override
  ConsumerState<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends ConsumerState<ChaptersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chapterNotifierProvider.notifier).loadChapters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterState = ref.watch(chapterNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.chapters,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showStudyGuideInfo,
          ),
        ],
      ),
      body: chapterState.isLoading
          ? LoadingWidget(message: l10n.loading)
          : chapterState.error != null
          ? ErrorDisplayWidget(
        message: chapterState.error!,
        onRetry: () => ref.read(chapterNotifierProvider.notifier).loadChapters(),
      )
          : chapterState.chapters.isEmpty
          ? const EmptyState(
        icon: Icons.book,
        title: 'No Chapters Available',
        message: 'Study materials are not available at the moment.',
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(chapterNotifierProvider.notifier).loadChapters(),
        child: Column(
          children: [
            // Study Progress Overview
            _buildStudyProgress(),

            // Chapters List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: chapterState.chapters.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: AppConstants.mediumAnimation,
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: ChapterCard(
                          chapter: chapterState.chapters[index],
                          onTap: () => _navigateToChapterDetail(chapterState.chapters[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyProgress() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(AppColors.primaryColor),
            Color(AppColors.primaryDark),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Life in the UK Study Guide',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Master all 5 chapters to pass the official test',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 6.0,
                  percent: 0.6, // This would be calculated based on actual progress
                  backgroundColor: Colors.white.withOpacity(0.3),
                  progressColor: Colors.white,
                  barRadius: const Radius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '60%', // This would be calculated
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToChapterDetail(Chapter chapter) {
    context.push(AppRoutes.chapterDetailPath(chapter.id));
  }

  void _showStudyGuideInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Guide'),
        content: const Text(
            'The Life in the UK Test covers 5 main chapters:\n\n'
                '• Chapter 1: Values and Principles\n'
                '• Chapter 2: What is the UK?\n'
                '• Chapter 3: A Long and Illustrious History\n'
                '• Chapter 4: A Modern, Thriving Society\n'
                '• Chapter 5: Government, Law and Your Role\n\n'
                'Study each chapter thoroughly and practice with the available tests.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Chapter Number Circle
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getChapterColor(chapter.chapterNumber).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getChapterColor(chapter.chapterNumber),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${chapter.chapterNumber}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getChapterColor(chapter.chapterNumber),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Chapter Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapter ${chapter.chapterNumber}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _getChapterColor(chapter.chapterNumber),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapter.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (chapter.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            chapter.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Test Statistics
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      context,
                      Icons.quiz_outlined,
                      '${chapter.totalTests}',
                      'Total Tests',
                    ),

                    const SizedBox(width: 24),

                    _buildStatItem(
                      context,
                      Icons.free_breakfast,
                      '${chapter.freeTests}',
                      'Free',
                    ),

                    const SizedBox(width: 24),

                    _buildStatItem(
                      context,
                      Icons.diamond,
                      '${chapter.premiumTests}',
                      'Premium',
                    ),

                    const Spacer(),

                    // Progress Indicator (if available)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getChapterColor(chapter.chapterNumber).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Study Now',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getChapterColor(chapter.chapterNumber),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getChapterColor(int chapterNumber) {
    const colors = [
      Color(AppColors.primaryColor),
      Color(AppColors.secondaryColor),
      Color(AppColors.accentColor),
      Color(AppColors.successColor),
      Color(AppColors.warningColor),
    ];

    return colors[(chapterNumber - 1) % colors.length];
  }
}

// Chapter Detail Screen
class ChapterDetailScreen extends ConsumerStatefulWidget {
  final int chapterId;

  const ChapterDetailScreen({
    super.key,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends ConsumerState<ChapterDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chapterNotifierProvider.notifier).loadChapterDetails(widget.chapterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterState = ref.watch(chapterNotifierProvider);
    final chapter = chapterState.selectedChapter;

    return Scaffold(
      appBar: CustomAppBar(
        title: chapter?.name ?? 'Chapter',
        actions: [
          if (chapter != null)
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _bookmarkChapter(chapter),
            ),
        ],
      ),
      body: chapterState.isLoading
          ? LoadingWidget(message: l10n.loading)
          : chapterState.error != null
          ? ErrorDisplayWidget(
        message: chapterState.error!,
        onRetry: () => ref.read(chapterNotifierProvider.notifier).loadChapterDetails(widget.chapterId),
      )
          : chapter == null
          ? const ErrorDisplayWidget(message: 'Chapter not found')
          : _buildChapterContent(chapter),
    );
  }

  Widget _buildChapterContent(Chapter chapter) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chapter Header
          _buildChapterHeader(chapter),

          // Chapter Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Study Overview
                _buildStudyOverview(chapter),

                const SizedBox(height: 20),

                // Key Topics (if available)
                _buildKeyTopics(chapter),

                const SizedBox(height: 20),

                // Available Tests
                _buildAvailableTests(chapter),

                const SizedBox(height: 20),

                // Study Tips
                _buildStudyTips(chapter),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterHeader(Chapter chapter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getChapterColor(chapter.chapterNumber),
            _getChapterColor(chapter.chapterNumber).withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Number Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'CHAPTER ${chapter.chapterNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Chapter Title
            Text(
              chapter.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            if (chapter.description != null) ...[
              const SizedBox(height: 12),
              Text(
                chapter.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudyOverview(Chapter chapter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    Icons.quiz_outlined,
                    '${chapter.totalTests}',
                    'Total Tests',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    Icons.free_breakfast,
                    '${chapter.freeTests}',
                    'Free Tests',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    Icons.diamond,
                    '${chapter.premiumTests}',
                    'Premium Tests',
                    const Color(AppColors.premiumGold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
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
    );
  }

  Widget _buildKeyTopics(Chapter chapter) {
    final keyTopics = _getKeyTopics(chapter.chapterNumber);

    if (keyTopics.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Topics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            ...keyTopics.map((topic) => _buildTopicItem(topic)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(String topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTests(Chapter chapter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Tests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Quick Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startQuickTest(chapter, 'free'),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Quick Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewAllTests(chapter),
                    icon: const Icon(Icons.list),
                    label: const Text('All Tests'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTips(Chapter chapter) {
    final tips = _getStudyTips(chapter.chapterNumber);

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

            const SizedBox(height: 12),

            ...tips.map((tip) => _buildTipItem(tip)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
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
    );
  }

  List<String> _getKeyTopics(int chapterNumber) {
    switch (chapterNumber) {
      case 1:
        return [
          'British values and principles',
          'Democracy and rule of law',
          'Individual liberty and respect',
          'Tolerance and community',
        ];
      case 2:
        return [
          'Geography of the UK',
          'Countries and capitals',
          'Population and languages',
          'Currency and national symbols',
        ];
      case 3:
        return [
          'Early British history',
          'Wars and conflicts',
          'Important historical figures',
          'Development of democracy',
        ];
      case 4:
        return [
          'Modern British society',
          'Arts and culture',
          'Sports and leisure',
          'Religion and communities',
        ];
      case 5:
        return [
          'UK government structure',
          'Legal system',
          'Voting and elections',
          'Rights and responsibilities',
        ];
      default:
        return [];
    }
  }

  List<String> _getStudyTips(int chapterNumber) {
    return [
      'Read through the official study guide carefully',
      'Take practice tests regularly to check your progress',
      'Focus on understanding concepts, not just memorizing facts',
      'Review your incorrect answers to learn from mistakes',
      'Study a little bit each day rather than cramming',
    ];
  }

  Color _getChapterColor(int chapterNumber) {
    const colors = [
      Color(AppColors.primaryColor),
      Color(AppColors.secondaryColor),
      Color(AppColors.accentColor),
      Color(AppColors.successColor),
      Color(AppColors.warningColor),
    ];

    return colors[(chapterNumber - 1) % colors.length];
  }

  void _bookmarkChapter(Chapter chapter) {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmarked ${chapter.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _startQuickTest(Chapter chapter, String type) {
    // TODO: Navigate to a quick test for this chapter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $type test for ${chapter.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _viewAllTests(Chapter chapter) {
    context.push('${AppRoutes.tests}?chapter=${chapter.id}');
  }
}