import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/attempt_model.dart';
import '../../../data/states/BilingualState.dart';
import '../../../shared/providers/bilingual_provider.dart';

class EnhancedReviewQuestionWidget extends ConsumerWidget {
  final AttemptAnswer answer;
  final int questionNumber;
  final int totalQuestions;

  const EnhancedReviewQuestionWidget({
    super.key,
    required this.answer,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🆕 NEW: Use dynamic bilingual state instead of showVietnamese
    final bilingualState = ref.watch(bilingualProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Header Card
            _buildQuestionHeaderCard(context, theme, isDark),

            const SizedBox(height: 24),

            // Question Text Card with Dynamic Multi-Language Support
            _buildQuestionTextCard(context, bilingualState, theme, isDark),

            const SizedBox(height: 24),

            // Answer Options Label
            Text(
              'Answer Options',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Answer Options List with Dynamic Multi-Language Support
            ...((answer.answerDetails ?? []).asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return _buildAnswerOption(
                context,
                option,
                index,
                bilingualState,
                theme,
                isDark,
              );
            }).toList()),

            const SizedBox(height: 24),

            // Explanation Section with Dynamic Multi-Language Support
            if (answer.explanation != null && answer.explanation!.isNotEmpty)
              _buildExplanationSection(context, bilingualState, theme, isDark),

            // Extra spacing at bottom
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeaderCard(BuildContext context, ThemeData theme, bool isDark) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: answer.isCorrect
              ? [AppColors.success.withValues(alpha: 0.1), AppColors.success.withValues(alpha: 0.05)]
              : [AppColors.error.withValues(alpha: 0.1), AppColors.error.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answer.isCorrect ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Row(
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
                  'Question $questionNumber',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: answer.isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  answer.isCorrect
                      ? 'Correct Answer'
                      : 'Incorrect Answer',
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
              color: (answer.isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
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
    );

  // Question Text Card with Dynamic Multi-Language Support
  Widget _buildQuestionTextCard(BuildContext context, BilingualState bilingualState, ThemeData theme, bool isDark) {
    return Container(
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
                'Question',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // English Question (Always shown)
          Text(
            answer.questionText ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),

          // Dynamic secondary language translation
          if (bilingualState.isEnabled && _hasQuestionTranslation(answer, bilingualState.secondaryLanguage)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    _getQuestionTranslation(answer, bilingualState.secondaryLanguage),
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
    );
  }

  // Answer Option with Dynamic Multi-Language Support
  Widget _buildAnswerOption(
      BuildContext context,
      AnswerOption option,
      int index,
      BilingualState bilingualState,
      ThemeData theme,
      bool isDark,
      ) {
    final isCorrect = option.isCorrect;
    final wasSelected = option.wasSelected;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? statusIcon;
    String? statusLabel;

    if (isCorrect) {
      backgroundColor = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success;
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      statusIcon = Icons.check_circle;
      statusLabel = 'Correct';
    } else if (wasSelected) {
      backgroundColor = AppColors.error.withValues(alpha: 0.15);
      borderColor = AppColors.error;
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      statusIcon = Icons.cancel;
      statusLabel = 'Your Answer';
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

          // Option Content with Dynamic Multi-Language Support
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English Answer (Always shown)
                Text(
                  option.answerText ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: (isCorrect || wasSelected) ? FontWeight.w600 : FontWeight.normal,
                    color: textColor,
                    height: 1.4,
                  ),
                ),

                // 🆕 ENHANCED: Dynamic secondary language translation
                if (bilingualState.isEnabled && _hasAnswerTranslation(option, bilingualState.secondaryLanguage)) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _getAnswerTranslation(option, bilingualState.secondaryLanguage),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.info,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
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

  // Explanation Section with Dynamic Multi-Language Support
  Widget _buildExplanationSection(BuildContext context, BilingualState bilingualState, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
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
                'Explanation',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // English Explanation (Always shown)
          Text(
            answer.explanation!,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),

          if (bilingualState.isEnabled && _hasExplanationTranslation(answer, bilingualState.secondaryLanguage)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getExplanationTranslation(answer, bilingualState.secondaryLanguage),
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
    );
  }

  bool _hasQuestionTranslation(AttemptAnswer answer, String languageCode) {
    return answer.hasQuestionTranslation(languageCode);
  }

  bool _hasAnswerTranslation(AnswerOption option, String languageCode) {
    return option.hasAnswerTranslation(languageCode);
  }

  bool _hasExplanationTranslation(AttemptAnswer answer, String languageCode) {
    return answer.hasExplanationTranslation(languageCode);
  }

  String _getQuestionTranslation(AttemptAnswer answer, String languageCode) {
    return answer.getQuestionText(languageCode: languageCode);
  }

  String _getAnswerTranslation(AnswerOption option, String languageCode) {
    return option.getAnswerText(languageCode: languageCode);
  }

  String _getExplanationTranslation(AttemptAnswer answer, String languageCode) {
    return answer.getExplanation(languageCode: languageCode);
  }
}