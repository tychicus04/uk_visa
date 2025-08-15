import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../providers/bilingual_provider.dart';

class LanguageToggleButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  const LanguageToggleButton({
    super.key,
    this.onPressed,
    this.showLabel = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bilingualState = ref.watch(bilingualProvider);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bilingualState.isEnabled
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bilingualState.isEnabled
              ? AppColors.primary
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onPressed ?? () {
          ref.read(bilingualProvider.notifier).toggleBilingual();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                bilingualState.isEnabled ? Icons.translate : Icons.language,
                color: bilingualState.isEnabled
                    ? AppColors.primary
                    : Colors.grey[600],
                size: 18,
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  bilingualState.isEnabled ? 'VI' : 'EN',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: bilingualState.isEnabled
                        ? AppColors.primary
                        : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}