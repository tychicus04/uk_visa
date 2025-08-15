// lib/features/home/widgets/quick_actions_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [

        // Start Practicing
        _buildActionCard(
          context,
          title: l10n.home_startPracticing,
          icon: Icons.play_arrow,
          trailing: const Icon(Icons.library_books, color: AppColors.primary),
          onTap: () {
            context.go('/tests');
          },
        ),
        const SizedBox(height: 16),

        // Read Study Book
        _buildActionCard(
          context,
          title: l10n.home_readStudyBook,
          icon: Icons.menu_book,
          trailing: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
          onTap: () {
            context.go('/chapters');
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget trailing,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
