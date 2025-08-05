import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/TestAttempt.dart';
import '../../data/models/UserAnswer.dart';
import '../../services/api_service.dart';
import '../../data/models/Test.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_app_bar.dart';

class AttemptDetailScreen extends ConsumerStatefulWidget {
  final int attemptId;

  const AttemptDetailScreen({
    super.key,
    required this.attemptId,
  });

  @override
  ConsumerState<AttemptDetailScreen> createState() => _AttemptDetailScreenState();
}

class _AttemptDetailScreenState extends ConsumerState<AttemptDetailScreen>
    with SingleTickerProviderStateMixin {
  TestAttempt? _attempt;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  String _filterBy = 'all'; // all, correct, incorrect

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttemptDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttemptDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final attempt = await ApiService.getAttemptDetails(widget.attemptId);

      if (mounted) {
        setState(() {
          _attempt = attempt;
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
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Test Results'),
        body: LoadingWidget(message: l10n.loading),
      );
    }

    if (_error != null || _attempt == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Test Results'),
        body: ErrorDisplayWidget(
          message: _error ?? 'Failed to load test details',
          onRetry: _loadAttemptDetails,
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Test Review',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResult,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'retake',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Retake Test'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Report Issue'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Result Header
          _buildResultHeader(),

          // Tab Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(text: 'Questions'),
                Tab(text: 'Summary'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsTab(),
                _buildSummaryTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _attempt!.isPassed ? Colors.green : Colors.red,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _attempt!.isPassed
              ? [Colors.green, Colors.green.shade700]
              : [Colors.red, Colors.red.shade700],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: AppConstants.mediumAnimation,
          child: SlideAnimation(
            verticalOffset: -30.0,
            child: FadeInAnimation(
              child: Column(
                children: [
                  // Test Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _attempt!.testTitle ?? 'Test',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_attempt!.chapterName != null)
                              Text(
                                _attempt!.chapterName!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Status Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _attempt!.isPassed ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Score Display
                  Row(
                    children: [
                      // Circular Progress
                      CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 6.0,
                        percent: (_attempt!.percentage! / 100).clamp(0.0, 1.0),
                        center: Text(
                          '${_attempt!.percentage!.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),

                      const SizedBox(width: 24),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderStat('Score', _attempt!.formattedScore),
                            _buildHeaderStat('Time', _attempt!.formattedTimeTaken),
                            _buildHeaderStat('Status', _attempt!.isPassed ? 'PASSED' : 'FAILED'),
                          ],
                        ),
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

  Widget _buildHeaderStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    if (_attempt!.answers.isEmpty) {
      return const Center(
        child: Text('No question details available'),
      );
    }

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Text(
                'Filter:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Correct', 'correct'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Incorrect', 'incorrect'),
                  ],
                ),
              ),

              Text(
                '${_getFilteredAnswers().length} questions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: _getFilteredAnswers().length,
            itemBuilder: (context, index) {
              final answer = _getFilteredAnswers()[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppConstants.shortAnimation,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: QuestionReviewCard(
                      answer: answer,
                      questionNumber: _attempt!.answers.indexOf(answer) + 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterBy == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : null,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    final correctAnswers = _attempt!.answers.where((a) => a.isCorrect).length;
    final incorrectAnswers = _attempt!.answers.length - correctAnswers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Performance Overview
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildPerformanceOverview(correctAnswers, incorrectAnswers),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Answer Breakdown
          AnimationConfiguration.staggeredList(
            position: 1,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildAnswerBreakdown(correctAnswers, incorrectAnswers),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recommendations
          AnimationConfiguration.staggeredList(
            position: 2,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildRecommendations(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(int correct, int incorrect) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Accuracy',
                    '${_attempt!.percentage!.toStringAsFixed(1)}%',
                    _attempt!.isPassed ? Colors.green : Colors.red,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Grade',
                    _getGrade(_attempt!.percentage!),
                    _getGradeColor(_attempt!.percentage!),
                    Icons.school,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Time Used',
                    _attempt!.formattedTimeTaken,
                    Colors.blue,
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Speed',
                    _getAnswerSpeed(),
                    Colors.purple,
                    Icons.speed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
      ),
    );
  }

  Widget _buildAnswerBreakdown(int correct, int incorrect) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Answer Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    'Correct',
                    correct.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildBreakdownItem(
                    'Incorrect',
                    incorrect.toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
                Expanded(
                  child: _buildBreakdownItem(
                    'Total',
                    _attempt!.answers.length.toString(),
                    Colors.blue,
                    Icons.quiz,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, Color color, IconData icon) {
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
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
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
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ..._getRecommendations().map((recommendation) =>
                _buildRecommendationItem(recommendation)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.tests),
                icon: const Icon(Icons.quiz),
                label: const Text('More Tests'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: _retakeTest,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retakeTest),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<UserAnswer> _getFilteredAnswers() {
    switch (_filterBy) {
      case 'correct':
        return _attempt!.answers.where((a) => a.isCorrect).toList();
      case 'incorrect':
        return _attempt!.answers.where((a) => !a.isCorrect).toList();
      case 'all':
      default:
        return _attempt!.answers;
    }
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 75) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 75) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getAnswerSpeed() {
    if (_attempt!.timeTaken == null) return 'Unknown';

    final secondsPerQuestion = _attempt!.timeTaken! / _attempt!.answers.length;

    if (secondsPerQuestion < 30) return 'Fast';
    if (secondsPerQuestion < 60) return 'Normal';
    return 'Slow';
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    final percentage = _attempt!.percentage!;

    if (!_attempt!.isPassed) {
      recommendations.add('Focus on reviewing the topics you got wrong');
      recommendations.add('Practice more tests to improve your score');
      recommendations.add('You need ${(75 - percentage).toStringAsFixed(1)}% more to pass');
    } else {
      recommendations.add('Great job! You passed the test');
      if (percentage < 90) {
        recommendations.add('Try to improve your score to 90% for excellent performance');
      }
    }

    final incorrectCount = _attempt!.answers.where((a) => !a.isCorrect).length;
    if (incorrectCount > 5) {
      recommendations.add('Review fundamental concepts - you missed $incorrectCount questions');
    }

    if (_attempt!.timeTaken != null && _attempt!.timeTaken! > 2400) { // 40 minutes
      recommendations.add('Try to manage your time better - aim for 30-35 minutes');
    }

    return recommendations;
  }

  void _shareResult() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${_attempt!.formattedPercentage} score!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'retake':
        _retakeTest();
        break;
      case 'report':
        _reportIssue();
        break;
    }
  }

  void _retakeTest() {
    context.push(AppRoutes.testDetailPath(_attempt!.testId));
  }

  void _reportIssue() {
    // TODO: Implement issue reporting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report issue functionality coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class QuestionReviewCard extends StatelessWidget {
  final UserAnswer answer;
  final int questionNumber;

  const QuestionReviewCard({
    super.key,
    required this.answer,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: answer.isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Q$questionNumber',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: answer.isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  answer.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: answer.isCorrect ? Colors.green : Colors.red,
                  size: 20,
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: answer.isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    answer.isCorrect ? 'CORRECT' : 'INCORRECT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: answer.isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question Text
            if (answer.questionText != null) ...[
              Text(
                answer.questionText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Answer Details
            if (answer.answerDetails != null && answer.answerDetails!.isNotEmpty) ...[
              ...answer.answerDetails!.map((answerDetail) {
                final wasSelected = answer.selectedAnswerIds.contains(answerDetail.answerId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAnswerBackgroundColor(answerDetail.isCorrect, wasSelected),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getAnswerBorderColor(answerDetail.isCorrect, wasSelected),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Answer ID
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getAnswerIdColor(answerDetail.isCorrect, wasSelected),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            answerDetail.answerId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Answer Text
                      Expanded(
                        child: Text(
                          answerDetail.answerText,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                      // Status Icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (answerDetail.isCorrect)
                            const Icon(Icons.check, color: Colors.green, size: 16),
                          if (wasSelected)
                            const Icon(Icons.person, color: Colors.blue, size: 16),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Legend
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLegendItem(Icons.check, 'Correct Answer', Colors.green),
                  const SizedBox(width: 16),
                  _buildLegendItem(Icons.person, 'Your Choice', Colors.blue),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getAnswerBackgroundColor(bool isCorrect, bool wasSelected) {
    if (isCorrect && wasSelected) {
      return Colors.green.withOpacity(0.1);
    } else if (isCorrect) {
      return Colors.green.withOpacity(0.05);
    } else if (wasSelected) {
      return Colors.red.withOpacity(0.1);
    } else {
      return Colors.transparent;
    }
  }

  Color _getAnswerBorderColor(bool isCorrect, bool wasSelected) {
    if (isCorrect && wasSelected) {
      return Colors.green;
    } else if (isCorrect) {
      return Colors.green.withOpacity(0.3);
    } else if (wasSelected) {
      return Colors.red;
    } else {
      return Colors.grey.withOpacity(0.3);
    }
  }

  Color _getAnswerIdColor(bool isCorrect, bool wasSelected) {
    if (isCorrect && wasSelected) {
      return Colors.green;
    } else if (isCorrect) {
      return Colors.green.withOpacity(0.7);
    } else if (wasSelected) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
}