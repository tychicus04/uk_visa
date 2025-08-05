import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: textColor ?? theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   icon,
          //   width: 20,
          //   height: 20,
          // ),
          Icon(Icons.login, size: 20), // Placeholder for social icons
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}