import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../providers/bilingual_provider.dart';
import '../../features/tests/widgets/bilingual_answer_option.dart';

class BilingualQuestionCard extends ConsumerWidget {
  final dynamic question;
  final int questionNumber;
  final List<String> selectedAnswerIds;
  final Function(String answerId) onAnswerSelected;
  final bool showResults;
  final bool isEnabled;

  const BilingualQuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.selectedAnswerIds,
    required this.onAnswerSelected,
    this.showResults = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bilingualState = ref.watch(bilingualProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Question Header with Language Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Language indicator
              if (bilingualState.isEnabled && question.hasVietnameseTranslation)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate,
                        size: 14,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'EN/VI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔥 Question Text (Bilingual)
          _buildQuestionText(question, bilingualState.isEnabled, theme),

          const SizedBox(height: 20),

          // 🔥 Answer Options
          ...question.answers.asMap().entries.map((entry) {
            final answer = entry.value;
            final isSelected = selectedAnswerIds.contains(answer.answerId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BilingualAnswerOption(
                answer: answer,
                isSelected: isSelected,
                questionType: question.questionType,
                onTap: isEnabled ? () => onAnswerSelected(answer.answerId) : () {},
              ),
            );
          }).toList(),

          // 🔥 Explanation (if available and bilingual enabled)
          if (showResults && question.explanation != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                  if (bilingualState.isEnabled && question.explanationVi != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.explanationVi,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionText(dynamic question, bool isVietnameseEnabled, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // English question
        Text(
          question.questionText,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),

        // Vietnamese translation (if enabled and available)
        if (isVietnameseEnabled &&
            question.questionTextVi != null &&
            question.questionTextVi.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            question.questionTextVi,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}