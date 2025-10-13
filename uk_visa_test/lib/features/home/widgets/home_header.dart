import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'language_selector.dart';
import 'theme_selector.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 60,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),

                  // Right side controls
                  const Row(
                    children: [
                      ThemeSelector(),
                      SizedBox(width: 8),
                      LanguageSelector(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}