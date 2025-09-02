import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../data/enums/CustomButtonVariant.dart';

class CustomButton extends StatelessWidget { // New parameter

  const CustomButton({
    required this.text, super.key,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.variant,
  });
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined; // Keep for backward compatibility
  final CustomButtonVariant? variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveVariant = variant ??
        (isOutlined ? CustomButtonVariant.outlined : CustomButtonVariant.primary);

    final Widget loadingWidget = SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getLoadingColor(effectiveVariant),
        ),
      ),
    );

    // Common icon or loading
    final iconWidget = isLoading
        ? loadingWidget
        : icon != null
        ? Icon(icon)
        : const SizedBox.shrink();

    // Build button based on variant
    switch (effectiveVariant) {
      case CustomButtonVariant.outlined:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: iconWidget,
            label: Text(text),
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? AppColors.primary,
              side: BorderSide(
                color: backgroundColor ?? AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );

      case CustomButtonVariant.text:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: TextButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: iconWidget,
            label: Text(text),
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );

      case CustomButtonVariant.primary:
      return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: iconWidget,
            label: Text(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              foregroundColor: textColor ?? Colors.white,
              elevation: 2,
              shadowColor: AppColors.shadowLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );
    }
  }

  Color _getLoadingColor(CustomButtonVariant variant) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return textColor ?? Colors.white;
      case CustomButtonVariant.outlined:
      case CustomButtonVariant.text:
        return textColor ?? AppColors.primary;
    }
  }
}

// Convenience constructors for easier usage
extension CustomButtonVariants on CustomButton {
  static CustomButton primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
      isLoading: isLoading,
      icon: icon,
      variant: CustomButtonVariant.primary,
    );
  }

  static CustomButton outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
      isLoading: isLoading,
      icon: icon,
      variant: CustomButtonVariant.outlined,
    );
  }

  static CustomButton text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
      isLoading: isLoading,
      icon: icon,
      variant: CustomButtonVariant.text,
    );
  }
}