// lib/features/tests/widgets/enhanced_review_question_widget.dart
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../data/models/attempt_model.dart';

class EnhancedReviewQuestionWidget extends StatelessWidget {
  final AttemptAnswer answer;
  final int questionNumber;
  final int totalQuestions;
  final bool showVietnamese;

  const EnhancedReviewQuestionWidget({
    super.key,
    required this.answer,
    required this.questionNumber,
    required this.totalQuestions,
    required this.showVietnamese,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: answer.isCorrect
                      ? [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)]
                      : [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: answer.isCorrect ? AppColors.success : AppColors.error,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Status Row
                  Row(
                    children: [
                      // Status Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: answer.isCorrect ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          answer.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Question Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.question ?? 'Question'} $questionNumber',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: answer.isCorrect ? AppColors.success : AppColors.error,
                              ),
                            ),
                            Text(
                              answer.isCorrect
                                  ? (l10n.correct_answer ?? 'Correct Answer!')
                                  : (l10n.incorrect_answer ?? 'Incorrect Answer'),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: answer.isCorrect ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Question Number Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (answer.isCorrect ? AppColors.success : AppColors.error).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$questionNumber/$totalQuestions',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: answer.isCorrect ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question Text Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Label
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.question ?? 'Question',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // English Question
                  Text(
                    answer.questionText ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  // Vietnamese Question
                  if (showVietnamese && answer.questionTextVi != null && answer.questionTextVi!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.translate,
                                color: AppColors.info,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tiếng Việt',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            answer.questionTextVi!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.info,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Answer Options
            Text(
              l10n.answer_options ?? 'Answer Options',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Answer Options List
            ...((answer.answerDetails ?? []).asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return _buildAnswerOption(
                context,
                option,
                index,
                theme,
                isDark,
                showVietnamese,
                l10n,
              );
            }).toList()),

            const SizedBox(height: 24),

            // Explanation Section
            if (answer.explanation != null && answer.explanation!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Explanation Header
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.explanation ?? 'Explanation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // English Explanation
                    Text(
                      answer.explanation!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),

                    // Vietnamese Explanation
                    if (showVietnamese && answer.explanationVi != null && answer.explanationVi!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.translate,
                                  color: AppColors.info,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Giải thích (Tiếng Việt)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              answer.explanationVi!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.info,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Extra spacing at bottom
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
      BuildContext context,
      AnswerOption option,
      int index,
      ThemeData theme,
      bool isDark,
      bool showVietnamese,
      AppLocalizations l10n,
      ) {
    final isCorrect = option.isCorrect;
    final wasSelected = option.wasSelected;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? statusIcon;
    String? statusLabel;

    if (isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.15);
      borderColor = AppColors.success;
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      statusIcon = Icons.check_circle;
      statusLabel = l10n.correct ?? 'Correct';
    } else if (wasSelected) {
      backgroundColor = AppColors.error.withOpacity(0.15);
      borderColor = AppColors.error;
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      statusIcon = Icons.cancel;
      statusLabel = l10n.your_answer ?? 'Your Answer';
    } else {
      backgroundColor = isDark ? AppColors.cardDark : AppColors.cardLight;
      borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          // Option Letter Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCorrect
                  ? AppColors.success
                  : wasSelected
                  ? AppColors.error
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrect
                    ? AppColors.success
                    : wasSelected
                    ? AppColors.error
                    : borderColor,
                width: 2,
              ),
            ),
            child: Center(
              child: (isCorrect || wasSelected)
                  ? Icon(
                statusIcon,
                color: Colors.white,
                size: 20,
              )
                  : Text(
                String.fromCharCode(65 + index), // A, B, C, D
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Option Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English Answer
                Text(
                  option.answerText ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: (isCorrect || wasSelected) ? FontWeight.w600 : FontWeight.normal,
                    color: textColor,
                    height: 1.4,
                  ),
                ),

                // Vietnamese Answer
                if (showVietnamese && option.answerTextVi != null && option.answerTextVi!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    option.answerTextVi!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.info,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status Badge
          if (statusLabel != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}