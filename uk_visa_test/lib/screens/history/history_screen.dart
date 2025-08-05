import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/TestAttempt.dart';
import '../../providers/user_notifier.dart';
import '../../data/models/Test.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_app_bar.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TestAttempt> _attempts = [];
  bool _isLoading = true;
  String? _error;
  String _sortBy = 'date'; // date, score, test_name
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final attempts = await ApiService.getAttemptHistory(page: 1, limit: 100);

      if (mounted) {
        setState(() {
          _attempts = attempts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.history,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? LoadingWidget(message: l10n.loading)
          : _error != null
          ? ErrorDisplayWidget(
        message: _error!,
        onRetry: _loadHistory,
      )
          : _attempts.isEmpty
          ? EmptyState(
        icon: Icons.history,
        title: 'No Test History',
        message: 'You haven\'t taken any tests yet. Start practicing to see your progress here!',
        actionText: 'Take a Test',
        onAction: () => context.push(AppRoutes.tests),
      )
          : Column(
        children: [
          // Tab Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'All Tests'),
                Tab(text: 'Statistics'),
                Tab(text: 'Progress'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTestsList(),
                _buildStatisticsTab(),
                _buildProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTestsList() {
    final sortedAttempts = _getSortedAttempts();

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: sortedAttempts.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppConstants.shortAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: TestAttemptCard(
                  attempt: sortedAttempts[index],
                  onTap: () => _viewAttemptDetails(sortedAttempts[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          _buildOverviewStats(),

          const SizedBox(height: 24),

          // Score Distribution Chart
          _buildScoreDistributionChart(),

          const SizedBox(height: 24),

          // Test Type Performance
          _buildTestTypePerformance(),

          const SizedBox(height: 24),

          // Recent Performance Trend
          _buildPerformanceTrend(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Learning Journey
          _buildLearningJourney(),

          const SizedBox(height: 24),

          // Chapter Progress
          _buildChapterProgress(),

          const SizedBox(height: 24),

          // Study Streak
          _buildStudyStreak(),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    final totalAttempts = _attempts.length;
    final passedAttempts = _attempts.where((a) => a.isPassed).length;
    final averageScore = totalAttempts > 0
        ? _attempts.map((a) => a.percentage ?? 0).reduce((a, b) => a + b) / totalAttempts
        : 0.0;
    final bestScore = totalAttempts > 0
        ? _attempts.map((a) => a.percentage ?? 0).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Tests',
                    totalAttempts.toString(),
                    Icons.quiz_outlined,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Passed',
                    passedAttempts.toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average Score',
                    '${averageScore.toStringAsFixed(1)}%',
                    Icons.trending_up_outlined,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Best Score',
                    '${bestScore.toStringAsFixed(1)}%',
                    Icons.star_outline,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDistributionChart() {
    final scoreRanges = <String, int>{
      '0-25%': 0,
      '26-50%': 0,
      '51-74%': 0,
      '75-89%': 0,
      '90-100%': 0,
    };

    for (final attempt in _attempts) {
      final score = attempt.percentage ?? 0;
      if (score <= 25) {
        scoreRanges['0-25%'] = scoreRanges['0-25%']! + 1;
      } else if (score <= 50) {
        scoreRanges['26-50%'] = scoreRanges['26-50%']! + 1;
      } else if (score < 75) {
        scoreRanges['51-74%'] = scoreRanges['51-74%']! + 1;
      } else if (score < 90) {
        scoreRanges['75-89%'] = scoreRanges['75-89%']! + 1;
      } else {
        scoreRanges['90-100%'] = scoreRanges['90-100%']! + 1;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: scoreRanges.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final ranges = scoreRanges.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < ranges.length) {
                            return Text(
                              ranges[value.toInt()],
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: scoreRanges.entries.map((entry) {
                    final index = scoreRanges.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getScoreRangeColor(entry.key),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTypePerformance() {
    final testTypes = <String, List<TestAttempt>>{};

    for (final attempt in _attempts) {
      final type = attempt.testType ?? 'Unknown';
      testTypes[type] = (testTypes[type] ?? [])..add(attempt);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance by Test Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            ...testTypes.entries.map((entry) {
              final type = entry.key;
              final attempts = entry.value;
              final avgScore = attempts.isNotEmpty
                  ? attempts.map((a) => a.percentage ?? 0).reduce((a, b) => a + b) / attempts.length
                  : 0.0;
              final passedCount = attempts.where((a) => a.isPassed).length;

              return _buildTestTypeItem(type, attempts.length, avgScore, passedCount);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTypeItem(String type, int totalTests, double avgScore, int passedTests) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${avgScore.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: avgScore >= 75 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                'Tests: $totalTests',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Passed: $passedTests',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrend() {
    if (_attempts.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Text(
                'Performance Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Take more tests to see your performance trend.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final recentAttempts = _attempts.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Performance Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < recentAttempts.length) {
                            return Text('${value.toInt() + 1}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: (recentAttempts.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: recentAttempts.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.percentage ?? 0);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningJourney() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Journey',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Journey milestones
            ..._buildJourneyMilestones(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildJourneyMilestones() {
    final milestones = [
      if (_attempts.isNotEmpty)
        _JourneyMilestone(
          title: 'First Test Taken',
          date: _attempts.last.startedAt,
          icon: Icons.play_circle_outline,
          color: Colors.blue,
        ),
      if (_attempts.where((a) => a.isPassed).isNotEmpty)
        _JourneyMilestone(
          title: 'First Test Passed',
          date: _attempts.where((a) => a.isPassed).last.completedAt ?? _attempts.where((a) => a.isPassed).last.startedAt,
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
      // Add more milestones as needed
    ];

    return milestones.map((milestone) => _buildMilestoneItem(milestone)).toList();
  }

  Widget _buildMilestoneItem(_JourneyMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: milestone.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              milestone.icon,
              color: milestone.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(milestone.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterProgress() {
    // Group attempts by chapter
    final chapterAttempts = <String, List<TestAttempt>>{};

    for (final attempt in _attempts) {
      final chapter = attempt.chapterName ?? 'Other';
      chapterAttempts[chapter] = (chapterAttempts[chapter] ?? [])..add(attempt);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            ...chapterAttempts.entries.map((entry) {
              final chapter = entry.key;
              final attempts = entry.value;
              final avgScore = attempts.isNotEmpty
                  ? attempts.map((a) => a.percentage ?? 0).reduce((a, b) => a + b) / attempts.length
                  : 0.0;

              return _buildChapterProgressItem(chapter, attempts.length, avgScore);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterProgressItem(String chapter, int testsCount, double avgScore) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$testsCount tests • ${avgScore.toStringAsFixed(1)}% avg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (avgScore / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: avgScore >= 75 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStreak() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Streak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_calculateStreak()} days',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Keep it going!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
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

  List<TestAttempt> _getSortedAttempts() {
    final attempts = List<TestAttempt>.from(_attempts);

    attempts.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'score':
          comparison = (a.percentage ?? 0).compareTo(b.percentage ?? 0);
          break;
        case 'test_name':
          comparison = (a.testTitle ?? '').compareTo(b.testTitle ?? '');
          break;
        case 'date':
        default:
          comparison = a.startedAt.compareTo(b.startedAt);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return attempts;
  }

  Color _getScoreRangeColor(String range) {
    switch (range) {
      case '0-25%':
        return Colors.red;
      case '26-50%':
        return Colors.orange;
      case '51-74%':
        return Colors.yellow;
      case '75-89%':
        return Colors.lightGreen;
      case '90-100%':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  int _calculateStreak() {
    if (_attempts.isEmpty) return 0;

    // Simple streak calculation - consecutive days with tests
    // This is a simplified version
    final recentAttempts = _attempts.take(30).toList();
    final dates = recentAttempts
        .map((a) => DateTime(a.startedAt.year, a.startedAt.month, a.startedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i-1].difference(dates[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
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

  void _viewAttemptDetails(TestAttempt attempt) {
    context.push(AppRoutes.attemptDetailPath(attempt.id));
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            ...['date', 'score', 'test_name'].map((option) {
              return ListTile(
                title: Text(_getSortOptionLabel(option)),
                leading: Radio<String>(
                  value: option,
                  groupValue: _sortBy,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            }).toList(),

            const Divider(),

            SwitchListTile(
              title: const Text('Ascending Order'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    // TODO: Implement filter options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Filter options coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _getSortOptionLabel(String option) {
    switch (option) {
      case 'date':
        return 'Date';
      case 'score':
        return 'Score';
      case 'test_name':
        return 'Test Name';
      default:
        return option;
    }
  }
}

class TestAttemptCard extends StatelessWidget {
  final TestAttempt attempt;
  final VoidCallback onTap;

  const TestAttemptCard({
    super.key,
    required this.attempt,
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
                  // Test Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: attempt.isPassed
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      attempt.isPassed ? Icons.check_circle : Icons.cancel,
                      color: attempt.isPassed ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Test Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attempt.testTitle ?? 'Test',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (attempt.chapterName != null)
                          Text(
                            attempt.chapterName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        attempt.formattedPercentage,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: attempt.isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        attempt.formattedScore,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attempt.formattedTimeTaken,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(attempt.startedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ],
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

class _JourneyMilestone {
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;

  _JourneyMilestone({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });
}