import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/question_model.dart';
import 'answer_option.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final List<String> selectedAnswers;
  final Function(String answerId, bool isSelected) onAnswerSelected;
  final bool showExplanation;
  final VoidCallback? onExplanationFeedback;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    this.showExplanation = false,
    this.onExplanationFeedback,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget>
    with TickerProviderStateMixin {
  late AnimationController _explanationController;
  late Animation<double> _explanationAnimation;
  bool _showExplanationOverlay = false;

  @override
  void initState() {
    super.initState();
    _explanationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _explanationAnimation = CurvedAnimation(
      parent: _explanationController,
      curve: Curves.easeInOut,
    );
  }

  void _showExplanation() {
    setState(() {
      _showExplanationOverlay = true;
    });
    _explanationController.forward();
  }

  void _hideExplanation() {
    _explanationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showExplanationOverlay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.question.questionText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (widget.question.explanation != null) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showExplanation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Show Explanation',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Answer Options
          ...widget.question.answers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;
            final isSelected = widget.selectedAnswers.contains(answer.answerId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: AnswerOption(
                        answer: answer,
                        isSelected: isSelected,
                        questionType: widget.question.questionType,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onAnswerSelected(answer.answerId, !isSelected);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),

      // Explanation Overlay
      if (_showExplanationOverlay && widget.question.explanation != null)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _explanationAnimation,
            builder: (context, child) => Opacity(
              opacity: _explanationAnimation.value,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5 * _explanationAnimation.value),
                child: Center(
                  child: Transform.scale(
                    scale: 0.7 + (0.3 * _explanationAnimation.value),
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "That's Correct!",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _hideExplanation,
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.question.explanation!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Was this explanation helpful?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    widget.onExplanationFeedback?.call();
                                    _hideExplanation();
                                  },
                                  icon: const Icon(Icons.thumb_up_outlined),
                                  label: const Text('Yes'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    widget.onExplanationFeedback?.call();
                                    _hideExplanation();
                                  },
                                  icon: const Icon(Icons.thumb_down_outlined),
                                  label: const Text('No'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }
}
