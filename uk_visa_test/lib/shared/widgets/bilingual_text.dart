// lib/shared/widgets/bilingual_text.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bilingual_provider.dart';

class BilingualText extends ConsumerWidget {

  const BilingualText({
    super.key,
    required this.englishText,
    this.vietnameseText,
    this.primaryStyle,
    this.secondaryStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.spacing = 4.0,
    this.forceShowBoth = false,
  });
  final String englishText;
  final String? vietnameseText;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double spacing;
  final bool forceShowBoth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowVietnamese = ref.watch(shouldShowVietnameseProvider);
    final hasVietnamese = vietnameseText != null && vietnameseText!.isNotEmpty;

    // Determine styles
    final defaultPrimaryStyle = primaryStyle ?? Theme.of(context).textTheme.bodyMedium;
    final defaultSecondaryStyle = secondaryStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        );

    // Single language mode
    if (!forceShowBoth && (!shouldShowVietnamese || !hasVietnamese)) {
      return Text(
        englishText,
        style: defaultPrimaryStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // Bilingual mode
    return Column(
      crossAxisAlignment: _getCrossAxisAlignment(textAlign),
      mainAxisSize: MainAxisSize.min,
      children: [
        // English text
        Text(
          englishText,
          style: defaultPrimaryStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
        if (hasVietnamese && spacing > 0) SizedBox(height: spacing),
        // Vietnamese text
        if (hasVietnamese)
          Text(
            vietnameseText!,
            style: defaultSecondaryStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
      ],
    );
  }

  CrossAxisAlignment _getCrossAxisAlignment(TextAlign? textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return CrossAxisAlignment.end;
      case TextAlign.left:
      case TextAlign.start:
      default:
        return CrossAxisAlignment.start;
    }
  }
}