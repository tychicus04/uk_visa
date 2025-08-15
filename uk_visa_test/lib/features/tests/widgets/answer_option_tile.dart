// lib/features/tests/widgets/answer_option_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';

class AnswerOptionTile extends StatefulWidget {
  const AnswerOptionTile({
    super.key,
    required this.answer,
    required this.isSelected,
    required this.isMultiSelect,
    required this.onTap,
    this.isVietnameseEnabled = false,
    this.animationDelay = Duration.zero,
    this.showCorrectAnswer = false,
    this.isCorrect,
  });

  final dynamic answer;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;
  final bool isVietnameseEnabled;
  final Duration animationDelay;
  final bool showCorrectAnswer;
  final bool? isCorrect;

  @override
  State<AnswerOptionTile> createState() => _AnswerOptionTileState();
}

class _AnswerOptionTileState extends State<AnswerOptionTile>
    with TickerProviderStateMixin {

  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rippleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for entrance
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Ripple animation for selection
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // Start entrance animation with delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void didUpdateWidget(AnswerOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected && widget.isSelected) {
      _rippleController.forward().then((_) {
        if (mounted) _rippleController.reset();
      });
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.showCorrectAnswer) {
      if (widget.isCorrect == true) {
        return AppColors.success.withOpacity(widget.isSelected ? 0.2 : 0.1);
      } else if (widget.isSelected && widget.isCorrect == false) {
        return AppColors.error.withOpacity(0.2);
      }
    }

    if (widget.isSelected) {
      return AppColors.primary;
    }

    return theme.colorScheme.surface;
  }

  Color _getBorderColor(ThemeData theme) {
    if (widget.showCorrectAnswer) {
      if (widget.isCorrect == true) {
        return AppColors.success;
      } else if (widget.isSelected && widget.isCorrect == false) {
        return AppColors.error;
      }
    }

    if (widget.isSelected) {
      return AppColors.primary;
    }

    return theme.colorScheme.outline.withOpacity(0.3);
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.showCorrectAnswer) {
      if (widget.isCorrect == true) {
        return AppColors.success;
      } else if (widget.isSelected && widget.isCorrect == false) {
        return AppColors.error;
      }
    }

    if (widget.isSelected) {
      return Colors.white;
    }

    return theme.colorScheme.onSurface;
  }

  Color _getBadgeColor(ThemeData theme) {
    if (widget.showCorrectAnswer) {
      if (widget.isCorrect == true) {
        return AppColors.success;
      } else if (widget.isSelected && widget.isCorrect == false) {
        return AppColors.error;
      }
    }

    if (widget.isSelected) {
      return Colors.white;
    }

    return AppColors.primary;
  }

  Color _getBadgeTextColor(ThemeData theme) {
    if (widget.showCorrectAnswer) {
      if (widget.isCorrect == true || (widget.isSelected && widget.isCorrect == false)) {
        return Colors.white;
      }
    }

    if (widget.isSelected) {
      return AppColors.primary;
    }

    return Colors.white;
  }

  Widget _buildSelectionIcon() {
    if (widget.showCorrectAnswer) {
      if (widget.isCorrect == true) {
        return Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 24,
        );
      } else if (widget.isSelected && widget.isCorrect == false) {
        return Icon(
          Icons.cancel,
          color: AppColors.error,
          size: 24,
        );
      }
    }

    if (widget.isMultiSelect) {
      return Icon(
        widget.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        color: widget.isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 24,
      );
    } else {
      return Icon(
        widget.isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: widget.isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 24,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getBackgroundColor(theme);
    final borderColor = _getBorderColor(theme);
    final textColor = _getTextColor(theme);
    final badgeColor = _getBadgeColor(theme);
    final badgeTextColor = _getBadgeTextColor(theme);

    // Accessibility label
    final accessibilityLabel = '${widget.answer.answerId}. ${widget.answer.answerText}'
        '${widget.isSelected ? ', selected' : ', not selected'}'
        '${widget.showCorrectAnswer && widget.isCorrect == true ? ', correct answer' : ''}'
        '${widget.showCorrectAnswer && widget.isSelected && widget.isCorrect == false ? ', incorrect' : ''}';

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Semantics(
          label: accessibilityLabel,
          button: true,
          selected: widget.isSelected,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _scaleController.forward();
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _scaleController.reverse();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _scaleController.reverse();
            },
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 2),
              constraints: const BoxConstraints(minHeight: 72),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  if (widget.isSelected) ...[
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] else ...[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ],
              ),
              child: Stack(
                children: [
                  // Ripple effect
                  if (widget.isSelected)
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(
                                (1 - _rippleAnimation.value) * 0.3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Answer badge (A, B, C, D, etc.)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: badgeColor.withOpacity(0.3),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Answer text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // English answer text
                              Text(
                                widget.answer.answerText,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),

                              // Vietnamese translation (if enabled and available)
                              if (widget.isVietnameseEnabled &&
                                  widget.answer.answerTextVi != null &&
                                  widget.answer.answerTextVi.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  widget.answer.answerTextVi,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Selection indicator
                        _buildSelectionIcon(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
}