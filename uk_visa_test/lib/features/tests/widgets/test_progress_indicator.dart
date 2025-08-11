// lib/features/tests/widgets/progress_indicator.dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class TestProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int timeRemaining; // in seconds
  final List<bool> answeredQuestions;

  const TestProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.timeRemaining,
    required this.answeredQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentQuestion / totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Question count and timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $currentQuestion of $totalQuestions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimerColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getTimerColor()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _getTimerColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(timeRemaining),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTimerColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),

          const SizedBox(height: 12),

          // Question Status Dots
          SizedBox(
            height: 24,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalQuestions,
              itemBuilder: (context, index) {
                final isCurrentQuestion = index == currentQuestion - 1;
                final isAnswered = index < answeredQuestions.length &&
                    answeredQuestions[index];

                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentQuestion
                        ? AppColors.primary
                        : isAnswered
                        ? AppColors.success
                        : AppColors.borderLight,
                    border: isCurrentQuestion
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isAnswered
                        ? Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                        : isCurrentQuestion
                        ? Text(
                      '${index + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    if (timeRemaining > 600) { // 10 minutes
      return AppColors.success;
    } else if (timeRemaining > 300) { // 5 minutes
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
