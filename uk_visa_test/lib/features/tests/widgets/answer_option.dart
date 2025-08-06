// lib/features/tests/widgets/answer_option.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class AnswerOption extends StatelessWidget {
  final dynamic answer;
  final bool isSelected;
  final String questionType;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.answer,
    required this.isSelected,
    required this.questionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : isDark
              ? AppColors.answerDefaultDark
              : AppColors.answerDefault,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: questionType == 'radio'
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: questionType == 'checkbox'
                    ? BorderRadius.circular(4)
                    : null,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                questionType == 'radio'
                    ? Icons.circle
                    : Icons.check,
                color: Colors.white,
                size: questionType == 'radio' ? 12 : 16,
              )
                  : null,
            ),

            const SizedBox(width: 16),

            // Answer ID Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  answer.answerId,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Answer Text
            Expanded(
              child: Text(
                answer.answerText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
