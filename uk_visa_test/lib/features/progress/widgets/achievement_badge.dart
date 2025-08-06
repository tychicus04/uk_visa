// lib/features/progress/widgets/achievement_badge.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final Color color;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? color.withOpacity(0.1)
            : (isDark ? AppColors.cardDark : AppColors.cardLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? color
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? color : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? Colors.white : AppColors.textSecondaryLight,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? color : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Lock overlay
          if (!isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                Icons.lock,
                size: 16,
                color: AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }
}