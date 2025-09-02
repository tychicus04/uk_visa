import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context, ref, authState.isAuthenticated, l10n),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.navigation_home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz_outlined),
            activeIcon: const Icon(Icons.quiz),
            label: l10n.navigation_tests,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.navigation_settings,
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/tests')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(
      int index,
      BuildContext context,
      WidgetRef ref,
      bool isAuthenticated,
      AppLocalizations l10n,
      ) {
    final routes = ['/', '/tests', '/settings'];
    final targetRoute = routes[index];

    // Check if the target route requires authentication
    final requiresAuth = _routeRequiresAuth(targetRoute);

    if (requiresAuth && !isAuthenticated) {
      _showAuthRequiredDialog(context, targetRoute, l10n);
    } else {
      GoRouter.of(context).go(targetRoute);
    }
  }

  bool _routeRequiresAuth(String route) {
    // Define which routes require authentication
    switch (route) {
      case '/tests':
        return true;
      case '/':
      case '/settings':
        return false;
      default:
        return false;
    }
  }

  void _showAuthRequiredDialog(BuildContext context, String targetRoute, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sign In Required',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getAuthRequiredMessage(targetRoute, l10n),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Features info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'What you\'ll get:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._getFeaturesList(targetRoute).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.common_cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Navigate to login with redirect
                    context.go('/login?redirect=${Uri.encodeComponent(targetRoute)}');
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/register?redirect=${Uri.encodeComponent(targetRoute)}');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    'Sign Up Free',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAuthRequiredMessage(String route, AppLocalizations l10n) {
    switch (route) {
      case '/tests':
        return 'You need to sign in to access practice tests and track your progress. Join thousands who are preparing for their UK citizenship test!';
      default:
        return 'You need to sign in to access this feature and save your progress.';
    }
  }

  List<String> _getFeaturesList(String route) {
    switch (route) {
      case '/tests':
        return [
          '1,080+ practice questions',
          '45 comprehensive tests',
          'Progress tracking & analytics',
          '8 language translations',
          'Timed practice sessions',
        ];
      default:
        return [
          'Track your progress',
          'Save your preferences',
          'Access premium features',
        ];
    }
  }
}