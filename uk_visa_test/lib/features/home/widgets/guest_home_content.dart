import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class GuestHomeContent extends ConsumerWidget {
  const GuestHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Message Card
        _buildWelcomeCard(context, l10n, theme, isDark),

        const SizedBox(height: 24),

        // Getting Started Actions
        _buildGettingStartedCard(context, l10n, theme, isDark),

        const SizedBox(height: 24),

        // Preview Features
        _buildPreviewFeaturesCard(context, l10n, theme, isDark),

        const SizedBox(height: 24),

        // Call to Action
        _buildCallToActionCard(context, l10n, theme, isDark),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome to UK Visa Test!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Prepare for your Life in the UK test with our comprehensive study materials and practice tests. Join thousands who have successfully passed their citizenship test!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              _buildStatItem('1,080+', 'Questions', theme, isDark),
              const SizedBox(width: 24),
              _buildStatItem('45', 'Practice Tests', theme, isDark),
              const SizedBox(width: 24),
              _buildStatItem('8', 'Languages', theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGettingStartedCard(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Started',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Action: Take Practice Tests (Requires login)
          _buildActionItem(
            context: context,
            icon: Icons.quiz_outlined,
            title: 'Take Practice Tests',
            subtitle: 'Sign in to access 1,080+ practice questions',
            color: AppColors.primary,
            onTap: () => context.go('/login?redirect=${Uri.encodeComponent('/tests')}'),
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewFeaturesCard(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Features Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Feature list
          _buildFeatureItem(
            icon: Icons.translate,
            title: 'Multi-language Support',
            description: '8 languages including Vietnamese, Polish, Arabic',
            theme: theme,
            isDark: isDark,
          ),

          _buildFeatureItem(
            icon: Icons.analytics_outlined,
            title: 'Progress Tracking',
            description: 'Track your performance and identify weak areas',
            theme: theme,
            isDark: isDark,
          ),

          _buildFeatureItem(
            icon: Icons.schedule,
            title: 'Flexible Practice',
            description: 'Study at your own pace with timed practice tests',
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCallToActionCard(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to Start Your Journey?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Join thousands of successful candidates. Create your free account now!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/register'),
                  icon: Icon(Icons.person_add, size: 20),
                  label: Text('Sign Up Free'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: Icon(Icons.login, size: 20),
                  label: Text('Sign In'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: color.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}