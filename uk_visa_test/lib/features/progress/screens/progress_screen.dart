// lib/features/progress/screens/progress_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../home/widgets/progress_card.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progressState = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progress_studyProgress),
      ),
      body: progressState.when(
        data: (progress) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                l10n.progress_trackExamReadiness,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 24),

              // Progress Overview
              Row(
                children: [
                  Expanded(
                    child: ProgressCard(
                      title: l10n.home_practiceProgress,
                      percentage: 76,
                      subtitle: l10n.home_dailyQuestionAnswered(29),
                      description: l10n.home_testsCompleted(34, 45),
                      color: AppColors.progressBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProgressCard(
                      title: l10n.home_readingProgress,
                      percentage: 89,
                      subtitle: l10n.home_sectionsRead(24, 27),
                      description: 'Progress: 89%',
                      color: AppColors.progressGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Score Statistics
              Text(
                l10n.progress_scoreStatistics,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildScoreStatistic(
                label: l10n.progress_lastTest,
                percentage: 90,
                color: AppColors.success,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildScoreStatistic(
                label: l10n.progress_lastNTests(5),
                percentage: 87,
                color: AppColors.progressBlue,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildScoreStatistic(
                label: l10n.progress_lastNTests(10),
                percentage: 79,
                color: AppColors.progressBlue,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildScoreStatistic(
                label: l10n.progress_lastNTests(20),
                percentage: 65,
                color: AppColors.progressRed,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildScoreStatistic(
                label: l10n.progress_allTests(23),
                percentage: 63,
                color: AppColors.progressRed,
                theme: theme,
              ),

              const SizedBox(height: 32),

              // Improvement Tips
              Text(
                l10n.progress_improveScore,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildTipCard(
                icon: Icons.trending_up,
                text: l10n.progress_goodProgress,
                color: AppColors.success,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                icon: Icons.menu_book,
                text: l10n.progress_continueReading,
                color: AppColors.primary,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                icon: Icons.access_time,
                text: l10n.progress_currentPracticeTime('10:00 AM'),
                color: AppColors.info,
                theme: theme,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(progressProvider),
        ),
      ),
    );
  }

  Widget _buildScoreStatistic({
    required String label,
    required int percentage,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: theme.brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String text,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

