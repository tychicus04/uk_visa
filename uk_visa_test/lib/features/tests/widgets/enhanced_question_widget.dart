import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/providers/bilingual_provider.dart';

class EnhancedQuestionWidget extends ConsumerWidget {
  final dynamic question;
  final int questionNumber;
  final int totalQuestions;
  final List<String> selectedAnswers;
  final Function(String answerId, bool isSelected) onAnswerSelected;

  const EnhancedQuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswers,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bilingualState = ref.watch(bilingualProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMultiSelect = question.questionType == 'checkbox';

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 QUESTION TEXT (BILINGUAL)
            _buildQuestionText(question, bilingualState.isEnabled, theme, isDark),

            const SizedBox(height: 20),

            // 🔥 ANSWER OPTIONS
            Expanded(
              child: ListView.separated(
                itemCount: question.answers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final answer = question.answers[index];
                  final isSelected = selectedAnswers.contains(answer.answerId);

                  return _buildAnswerOption(
                    answer: answer,
                    isSelected: isSelected,
                    isVietnameseEnabled: bilingualState.isEnabled,
                    isMultiSelect: isMultiSelect,
                    onTap: () {
                      onAnswerSelected(answer.answerId, !isSelected);
                    },
                    theme: theme,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 QUESTION TEXT (BILINGUAL)
  Widget _buildQuestionText(dynamic question, bool isVietnameseEnabled, ThemeData theme, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // English question
      Text(
        question.questionText,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),

      // Vietnamese translation (if enabled and available)
      if (isVietnameseEnabled &&
          question.questionTextVi != null &&
          question.questionTextVi.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.questionTextVi,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  // 🔥 ANSWER OPTION WITH LARGE TOUCH TARGET
  Widget _buildAnswerOption({
    required dynamic answer,
    required bool isSelected,
    required bool isVietnameseEnabled,
    required bool isMultiSelect,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    // Theme-aware colors
    final backgroundColor = isSelected
        ? AppColors.primary.withOpacity(isDark ? 0.15 : 0.1)
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final badgeBackgroundColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : Colors.white);

    final badgeBorderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : Colors.grey[400]!);

    final badgeTextColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : Colors.grey[700]);

    final answerTextColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final vietnameseTextColor = isSelected
        ? AppColors.primary.withOpacity(0.8)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    final iconColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.iconDark : AppColors.iconLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected && !isDark ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : (isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]),
          ),
          child: Row(
            children: [
              // Answer letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badgeBorderColor,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Center(
                  child: Text(
                    answer.answerId,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Answer text (bilingual)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // English answer
                    Text(
                      answer.answerText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: answerTextColor,
                      ),
                    ),

                    // Vietnamese translation (if enabled and available)
                    if (isVietnameseEnabled &&
                        answer.answerTextVi != null &&
                        answer.answerTextVi.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              answer.answerTextVi,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: vietnameseTextColor,
                                fontStyle: FontStyle.italic,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isMultiSelect
                      ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                      : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  color: iconColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}