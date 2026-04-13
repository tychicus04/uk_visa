// lib/features/tests/widgets/enhanced_question_widget.dart - UPDATED with Multi-Language Support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/states/BilingualState.dart';
import '../../../shared/providers/bilingual_provider.dart';

// 🆕 Enum for different answer states
enum AnswerState {
  normal,              // Default state
  selected,           // User selected but not showing correct answers yet
  correctSelected,    // User selected correct answer (green)
  correctNotSelected, // Correct answer not selected by user (light green)
  incorrectSelected,  // User selected incorrect answer (red)
}

class EnhancedQuestionWidget extends ConsumerWidget {
  final dynamic question;
  final int questionNumber;
  final int totalQuestions;
  final List<String> selectedAnswers;
  final bool isAnswered;
  final bool? isCorrect; // null = not answered, true = correct, false = incorrect
  final List<String>? correctAnswers; // 🆕 Show correct answers
  final bool showCorrectAnswers; // 🆕 Whether to highlight correct answers
  final bool allowAnswerChange; // 🆕 Whether to allow changing answers after selection (true for Exam mode)
  final Function(String answerId, bool isSelected) onAnswerSelected;

  const EnhancedQuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswers,
    required this.isAnswered,
    required this.isCorrect,
    this.correctAnswers,
    this.showCorrectAnswers = false,
    this.allowAnswerChange = false, // Default: không cho phép chọn lại (Practice mode)
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
            _buildQuestionText(question, bilingualState, theme, isDark),

            // 🔄 UPDATED: Only show feedback when showCorrectAnswers is true (Practice mode)
            if (isAnswered && isCorrect != null && showCorrectAnswers) ...[
              const SizedBox(height: 16),
              _buildAnswerFeedback(isCorrect!, theme, isDark),
            ],

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: question.answers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final answer = question.answers[index];
                  final isSelected = selectedAnswers.contains(answer.answerId);
                  final isCorrectAnswer = correctAnswers?.contains(answer.answerId) ?? false;
                  
                  // Determine answer state for visual feedback
                  AnswerState answerState = AnswerState.normal;
                  if (isAnswered && showCorrectAnswers) {
                    if (isCorrectAnswer && isSelected) {
                      answerState = AnswerState.correctSelected; // Green - user selected correct answer
                    } else if (isCorrectAnswer && !isSelected) {
                      answerState = AnswerState.correctNotSelected; // Light green - correct answer not selected
                    } else if (!isCorrectAnswer && isSelected) {
                      answerState = AnswerState.incorrectSelected; // Red - user selected wrong answer
                    } else {
                      answerState = AnswerState.normal; // Normal - not selected, not correct
                    }
                  } else if (isSelected) {
                    answerState = AnswerState.selected; // Blue - selected but not yet showing answers
                  }

                  return _buildAnswerOption(
                    answer: answer,
                    isSelected: isSelected,
                    answerState: answerState,
                    bilingualState: bilingualState,
                    isMultiSelect: isMultiSelect,
                    isAnswered: isAnswered, // 🆕 Pass isAnswered to control interactivity
                    allowAnswerChange: allowAnswerChange, // 🆕 Pass allowAnswerChange flag
                    onTap: () {
                      // 🔥 UPDATED: Only prevent changes in Practice mode after answering
                      // In Exam mode, allow changing answers anytime
                      if (isAnswered && !allowAnswerChange) {
                        return; // Practice mode: Do nothing if question has already been answered
                      }
                      
                      // For radio questions in Exam mode, allow re-selecting (changing answer)
                      // For radio questions in Practice mode with allowAnswerChange=false,
                      // we already returned above if isAnswered=true
                      
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

  // 🔥 QUESTION TEXT (MULTI-LANGUAGE)
  Widget _buildQuestionText(dynamic question, BilingualState bilingualState, ThemeData theme, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // English question (always shown)
      Text(
        question.questionText,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),

      if (bilingualState.isEnabled && _hasQuestionTranslation(question, bilingualState.secondaryLanguage)) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _getQuestionTranslation(question, bilingualState.secondaryLanguage),
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

  // 🆕 ANSWER FEEDBACK WIDGET (hiển thị đúng/sai ngay lập tức)
  Widget _buildAnswerFeedback(bool isCorrect, ThemeData theme, bool isDark) {
    final feedbackColor = isCorrect ? AppColors.success : AppColors.error;
    final feedbackIcon = isCorrect ? Icons.check_circle : Icons.cancel;
    final feedbackText = isCorrect ? 'Correct!' : 'Incorrect!';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feedbackColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            feedbackIcon,
            color: feedbackColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feedbackText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: feedbackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ANSWER OPTION WITH LARGE TOUCH TARGET
  Widget _buildAnswerOption({
    required dynamic answer,
    required bool isSelected,
    required AnswerState answerState, // 🆕 New parameter for answer state
    required BilingualState bilingualState,
    required bool isMultiSelect,
    required bool isAnswered, // 🆕 New parameter to control interactivity
    required bool allowAnswerChange, // 🆕 New parameter to allow changing answers
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    // 🆕 Enhanced theme-aware colors based on answer state
    Color backgroundColor;
    Color borderColor;
    Color badgeBackgroundColor;
    Color badgeBorderColor;
    Color? badgeTextColor;
    Color answerTextColor;
    Color secondaryTextColor;
    Color iconColor;

    switch (answerState) {
      case AnswerState.correctSelected:
        // Green theme for correct answer selected by user
        backgroundColor = AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1);
        borderColor = AppColors.success;
        badgeBackgroundColor = AppColors.success;
        badgeBorderColor = AppColors.success;
        badgeTextColor = Colors.white;
        answerTextColor = AppColors.success;
        secondaryTextColor = AppColors.success.withValues(alpha: 0.8);
        iconColor = AppColors.success;
        break;
        
      case AnswerState.correctNotSelected:
        // Light green theme for correct answer not selected
        backgroundColor = AppColors.success.withValues(alpha: isDark ? 0.08 : 0.05);
        borderColor = AppColors.success.withValues(alpha: 0.6);
        badgeBackgroundColor = AppColors.success.withValues(alpha: 0.6);
        badgeBorderColor = AppColors.success.withValues(alpha: 0.6);
        badgeTextColor = Colors.white;
        answerTextColor = AppColors.success.withValues(alpha: 0.8);
        secondaryTextColor = AppColors.success.withValues(alpha: 0.6);
        iconColor = AppColors.success.withValues(alpha: 0.6);
        break;
        
      case AnswerState.incorrectSelected:
        // Red theme for incorrect answer selected by user
        backgroundColor = AppColors.error.withValues(alpha: isDark ? 0.15 : 0.1);
        borderColor = AppColors.error;
        badgeBackgroundColor = AppColors.error;
        badgeBorderColor = AppColors.error;
        badgeTextColor = Colors.white;
        answerTextColor = AppColors.error;
        secondaryTextColor = AppColors.error.withValues(alpha: 0.8);
        iconColor = AppColors.error;
        break;
        
      case AnswerState.selected:
        // Blue theme for selected answer (before showing correct answers)
        backgroundColor = AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1);
        borderColor = AppColors.primary;
        badgeBackgroundColor = AppColors.primary;
        badgeBorderColor = AppColors.primary;
        badgeTextColor = Colors.white;
        answerTextColor = AppColors.primary;
        secondaryTextColor = AppColors.primary.withValues(alpha: 0.8);
        iconColor = AppColors.primary;
        break;
        
      case AnswerState.normal:
        // Default theme for unselected answers
        backgroundColor = isDark ? AppColors.cardDark : AppColors.cardLight;
        borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
        badgeBackgroundColor = isDark ? AppColors.surfaceDark : Colors.white;
        badgeBorderColor = isDark ? AppColors.borderDark : Colors.grey[400]!;
        badgeTextColor = isDark ? AppColors.textPrimaryDark : Colors.grey[700];
        answerTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        iconColor = isDark ? AppColors.iconDark : AppColors.iconLight;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (isAnswered && !allowAnswerChange) ? null : onTap, // 🔥 UPDATED: Disable only when answered AND not allowed to change (Practice mode)
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: (answerState != AnswerState.normal) ? 2 : 1,
            ),
            boxShadow: (answerState != AnswerState.normal) && !isDark ? [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : (isDark ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                  boxShadow: (answerState != AnswerState.normal) ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.3),
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

              // Answer text (multi-language)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // English answer (always shown)
                    Text(
                      answer.answerText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: answerTextColor,
                      ),
                    ),

                    // 🆕 ENHANCED: Secondary language translation (if enabled and available)
                    if (bilingualState.isEnabled && _hasAnswerTranslation(answer, bilingualState.secondaryLanguage)) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _getAnswerTranslation(answer, bilingualState.secondaryLanguage),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: secondaryTextColor,
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

  // 🆕 NEW: Helper methods for dynamic translation checking
  bool _hasQuestionTranslation(dynamic question, String languageCode) {
    return question.hasTranslation(languageCode);
  }

  bool _hasAnswerTranslation(dynamic answer, String languageCode) {
    return answer.hasTranslation(languageCode);
  }

  String _getQuestionTranslation(dynamic question, String languageCode) {
    return question.getQuestionText(languageCode: languageCode);
  }

  String _getAnswerTranslation(dynamic answer, String languageCode) {
    return answer.getAnswerText(languageCode: languageCode);
  }
}