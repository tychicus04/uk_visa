import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/TestAttempt.dart';
import '../../providers/app_providers.dart';
import '../../providers/test_notifier.dart';
import '../../data/models/Test.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_button.dart';

class TestResultScreen extends ConsumerStatefulWidget {
  final int testId;
  final int attemptId;

  const TestResultScreen({
    super.key,
    required this.testId,
    required this.attemptId,
  });

  @override
  ConsumerState<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends ConsumerState<TestResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late ConfettiController _confettiController;
  TestAttempt? _attempt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _loadAttemptDetails();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadAttemptDetails() async {
    try {
      final attempt = await ref.read(testNotifierProvider.notifier).getAttemptDetails(widget.attemptId);
      if (mounted) {
        setState(() {
          _attempt = attempt;
          _isLoading = false;
        });

        // Start animations
        _scaleController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        _slideController.forward();

        // Show confetti for passed tests
        if (attempt?.isPassed == true) {
          _confettiController.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading results...'),
      );
    }

    if (_attempt == null) {
      return Scaffold(
        body: ErrorDisplayWidget(
          message: 'Failed to load test results',
          onRetry: _loadAttemptDetails,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _navigateHome(),
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: _navigateHome,
                  ),
                  backgroundColor: _attempt!.isPassed ? Colors.green : Colors.red,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _shareResult,
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Score Card
                      _buildScoreCard(),

                      const SizedBox(height: 20),

                      // Performance Analysis
                      _buildPerformanceAnalysis(),

                      const SizedBox(height: 20),

                      // Question Breakdown
                      _buildQuestionBreakdown(),

                      const SizedBox(height: 20),

                      // Action Buttons
                      _buildActionButtons(),

                      const SizedBox(height: 100), // Bottom padding
                    ]),
                  ),
                ),
              ],
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708, // radians for downward
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _attempt!.isPassed
              ? [Colors.green, Colors.green.shade700]
              : [Colors.red, Colors.red.shade700],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleController.value,
                    child: Icon(
                      _attempt!.isPassed ? Icons.check_circle : Icons.cancel,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              Text(
                _attempt!.isPassed
                    ? l10n.congratulations
                    : l10n.keepTrying,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                _attempt!.isPassed
                    ? l10n.testPassedMessage(_attempt!.formattedPercentage)
                    : l10n.testFailedMessage(_attempt!.formattedPercentage),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Circular Progress
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 12.0,
                      percent: (_attempt!.percentage! / 100).clamp(0.0, 1.0),
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_attempt!.percentage!.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _attempt!.isPassed ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            _attempt!.formattedScore,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      progressColor: _attempt!.isPassed ? Colors.green : Colors.red,
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    ),

                    const SizedBox(height: 20),

                    // Pass/Fail Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _attempt!.isPassed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _attempt!.isPassed ? 'PASSED' : 'FAILED',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _attempt!.isPassed ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time Taken
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Time taken: ${_attempt!.formattedTimeTaken}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceAnalysis() {
    return AnimationConfiguration.staggeredList(
      position: 1,
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
                    'Performance Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildAnalysisItem(
                    'Accuracy',
                    '${_attempt!.percentage!.toStringAsFixed(1)}%',
                    _attempt!.isPassed ? Colors.green : Colors.red,
                  ),

                  _buildAnalysisItem(
                    'Performance Level',
                    _getPerformanceLevel(_attempt!.percentage!),
                    _getPerformanceLevelColor(_attempt!.percentage!),
                  ),

                  _buildAnalysisItem(
                    'Time Efficiency',
                    _getTimeEfficiency(),
                    Colors.blue,
                  ),

                  if (!_attempt!.isPassed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You need ${(75 - _attempt!.percentage!).toStringAsFixed(1)}% more to pass. Keep practicing!',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade700,
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
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBreakdown() {
    if (_attempt!.answers.isEmpty) {
      return const SizedBox.shrink();
    }

    final correctAnswers = _attempt!.answers.where((a) => a.isCorrect).length;
    final incorrectAnswers = _attempt!.answers.length - correctAnswers;
    final l10n = AppLocalizations.of(context)!;

    return AnimationConfiguration.staggeredList(
      position: 2,
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
                    'Question Breakdown',
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
                          correctAnswers.toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _buildBreakdownItem(
                          'Incorrect',
                          incorrectAnswers.toString(),
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

                  const SizedBox(height: 16),

                  // Review Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _reviewAnswers,
                      icon: const Icon(Icons.visibility),
                      label: Text(l10n.reviewAnswers),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: AppConstants.mediumAnimation,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              // Primary Action
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressed: _retakeTest,
                  isLoading: false,
                  text: l10n.retakeTest,
                  icon: Icons.refresh,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _viewOtherTests,
                      icon: const Icon(Icons.quiz),
                      label: const Text('Other Tests'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _navigateHome,
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPerformanceLevel(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Good';
    if (percentage >= 75) return 'Pass';
    if (percentage >= 60) return 'Fair';
    return 'Needs Improvement';
  }

  Color _getPerformanceLevelColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 75) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getTimeEfficiency() {
    if (_attempt!.timeTaken == null) return 'Unknown';

    final minutes = _attempt!.timeTaken! ~/ 60;
    if (minutes < 20) return 'Very Fast';
    if (minutes < 30) return 'Fast';
    if (minutes < 40) return 'Good';
    return 'Adequate';
  }

  void _retakeTest() {
    context.pushReplacement(AppRoutes.testDetailPath(widget.testId));
  }

  void _reviewAnswers() {
    context.push(AppRoutes.attemptDetailPath(_attempt!.id));
  }

  void _viewOtherTests() {
    context.go(AppRoutes.tests);
  }

  void _navigateHome() {
    context.go(AppRoutes.home);
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
}