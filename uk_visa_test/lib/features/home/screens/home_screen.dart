import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../widgets/authenticated_home_content.dart';
import '../widgets/guest_home_content.dart';
import '../widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Common Header for all users
          HomeHeader(),

          // Content based on auth state
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Show different content based on authentication
                if (authState.isLoading)
                  _buildLoadingState(context)
                else if (authState.isAuthenticated && authState.user != null)
                  AuthenticatedHomeContent()
                else
                  GuestHomeContent(),

                const SizedBox(height: 100), // Bottom padding for navigation
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}