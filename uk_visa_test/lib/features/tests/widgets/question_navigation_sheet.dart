import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class QuestionNavigationSheet extends StatelessWidget {
  final dynamic test;
  final int currentQuestionIndex;
  final Map<String, List<String>> answers;
  final Function(int index) onQuestionTap;

  const QuestionNavigationSheet({
    super.key,
    required this.test,
    required this.currentQuestionIndex,
    required this.answers,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = test.questions?.length ?? 24;
    final answeredCount = answers.values.where((answers) => answers.isNotEmpty).length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 HANDLE BAR
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 🔥 HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Question Navigator',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$answeredCount of $totalQuestions questions answered',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // 🔥 LEGEND
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  color: AppColors.primary,
                  label: 'Current',
                  icon: Icons.location_on,
                  isDark: isDark,
                ),
                _buildLegendItem(
                  color: AppColors.success,
                  label: 'Answered',
                  icon: Icons.check_circle,
                  isDark: isDark,
                ),
                _buildLegendItem(
                  color: isDark ? AppColors.borderDark : Colors.grey[300]!,
                  label: 'Not Answered',
                  icon: Icons.radio_button_unchecked,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 QUESTION GRID
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  final questionId = test.questions?[index]?.id ?? index.toString();
                  final isAnswered = answers[questionId]?.isNotEmpty ?? false;
                  final isCurrent = index == currentQuestionIndex;

                  return _buildQuestionButton(
                    questionNumber: index + 1,
                    isAnswered: isAnswered,
                    isCurrent: isCurrent,
                    onTap: () => onQuestionTap(index),
                    isDark: isDark,
                  );
                },
              ),
            ),
          ),

          // 🔥 BOTTOM ACTIONS
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.primary.withOpacity(0.3)
                      ),
                      foregroundColor: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.primary,
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: answeredCount == totalQuestions
                        ? () {
                      Navigator.pop(context);
                      // Trigger submit from parent
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit Test'),
                  ),
                ),
              ],
            ),
          ),

          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionButton({
    required int questionNumber,
    required bool isAnswered,
    required bool isCurrent,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (isCurrent) {
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
      icon = Icons.location_on;
    } else if (isAnswered) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
      textColor = AppColors.success;
      icon = Icons.check;
    } else {
      backgroundColor = isDark ? AppColors.cardDark : Colors.grey[100]!;
      borderColor = isDark ? AppColors.borderDark : Colors.grey[300]!;
      textColor = isDark ? AppColors.textSecondaryDark : Colors.grey[600]!;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  questionNumber.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),

              // Status icon
              if (icon != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    icon,
                    size: 12,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}