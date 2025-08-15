import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/providers/bilingual_provider.dart';

class BilingualAnswerOption extends ConsumerStatefulWidget {
  final dynamic answer;
  final bool isSelected;
  final String questionType;
  final VoidCallback onTap;

  const BilingualAnswerOption({
    super.key,
    required this.answer,
    required this.isSelected,
    required this.questionType,
    required this.onTap,
  });

  @override
  ConsumerState<BilingualAnswerOption> createState() => _BilingualAnswerOptionState();
}

class _BilingualAnswerOptionState extends ConsumerState<BilingualAnswerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bilingualState = ref.watch(bilingualProvider);
    final hasVietnamese = widget.answer.answerTextVi != null &&
        widget.answer.answerTextVi.isNotEmpty;

    // 🎨 Dynamic colors based on selection
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color badgeColor;
    Color badgeTextColor;

    if (widget.isSelected) {
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
      badgeColor = Colors.white;
      badgeTextColor = AppColors.primary;
    } else {
      backgroundColor = Colors.grey[100]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.black87;
      badgeColor = AppColors.primary;
      badgeTextColor = Colors.white;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: widget.isSelected
                    ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                children: [
                  // 🔥 Answer Letter Badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.answer.answerId,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 🔥 Answer Text (Bilingual)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // English answer
                        Text(
                          widget.answer.answerText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),

                        // Vietnamese translation (if enabled and available)
                        if (bilingualState.isEnabled && hasVietnamese) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.answer.answerTextVi,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: widget.isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 🔥 Selection Indicator
                  if (widget.isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 14,
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