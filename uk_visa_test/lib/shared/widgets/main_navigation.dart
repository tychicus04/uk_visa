// lib/shared/widgets/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
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
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: l10n.navigation_book,
          ),
          // BottomNavigationBarItem(
          //   icon: const Icon(Icons.analytics_outlined),
          //   activeIcon: const Icon(Icons.analytics),
          //   label: l10n.navigation_progress,
          // ),
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
    if (location.startsWith('/chapters')) {
      return 2;
    }
    // if (location.startsWith('/progress')) {
    //   return 3;
    // }
    if (location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/tests');
        break;
      case 2:
        GoRouter.of(context).go('/chapters');
        break;
      // case 3:
      //   GoRouter.of(context).go('/progress');
      //   break;
      case 3:
        GoRouter.of(context).go('/settings');
        break;
    }
  }
}