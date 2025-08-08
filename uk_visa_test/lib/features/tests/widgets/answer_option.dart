// lib/features/tests/widgets/answer_option.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/answer_model.dart';

class AnswerOption extends StatefulWidget {
  final Answer answer;
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
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.blue.withOpacity(0.1),
    ).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : _colorAnimation.value,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.blue
                      : isDark
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                children: [
                  // Selection Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: widget.questionType == 'radio'
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: widget.questionType == 'checkbox'
                          ? BorderRadius.circular(4)
                          : null,
                      color: widget.isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: widget.isSelected
                            ? Colors.blue
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? Icon(
                      widget.questionType == 'radio'
                          ? Icons.circle
                          : Icons.check,
                      color: Colors.white,
                      size: widget.questionType == 'radio' ? 12 : 16,
                    )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Answer ID Badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.blue
                          : isDark
                          ? Colors.grey[700]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.answer.answerId,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: widget.isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Answer Text
                  Expanded(
                    child: Text(
                      widget.answer.answerText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: widget.isSelected
                            ? Colors.blue
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}