import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../providers/app_providers.dart';
import '../../screens/chapters/chapters_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/tests/tests_screen.dart';
import '../../screens/tests/tests_detail_screen.dart';
import '../../screens/tests/test_taking_screen.dart';
import '../../screens/tests/test_result_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/history/attempt_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/premium/premium_screen.dart';
import '../../screens/chapters/chapters_detail_screen.dart';
import '../../providers/auth_notifier.dart';
import '../../utils/secure_storage.dart';
import '../../utils/logger.dart';

/// Route names for easy navigation
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String tests = '/tests';
  static const String testDetail = '/tests/:testId';
  static const String testTaking = '/tests/:testId/take';
  static const String testResult = '/tests/:testId/result/:attemptId';
  static const String history = '/history';
  static const String attemptDetail = '/history/:attemptId';
  static const String chapters = '/chapters';
  static const String chapterDetail = '/chapters/:chapterId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String premium = '/premium';

  // Helper methods for navigation with parameters
  static String testDetailPath(int testId) => '/tests/$testId';
  static String testTakingPath(int testId) => '/tests/$testId/take';
  static String testResultPath(int testId, int attemptId) => '/tests/$testId/result/$attemptId';
  static String attemptDetailPath(int attemptId) => '/history/$attemptId';
  static String chapterDetailPath(int chapterId) => '/chapters/$chapterId';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Redirect logic based on authentication state
    redirect: (context, state) async {
      final isLoggedIn = ref.read(authNotifierProvider).isAuthenticated;
      final isOnboardingCompleted = await SecureStorage.isOnboardingCompleted();
      final currentLocation = state.uri.toString();

      Logger.info('Router redirect - Location: $currentLocation, LoggedIn: $isLoggedIn, OnboardingCompleted: $isOnboardingCompleted');

      // Don't redirect from splash screen
      if (currentLocation == AppRoutes.splash) {
        return null;
      }

      // If not onboarded, redirect to onboarding (except auth screens)
      if (!isOnboardingCompleted &&
          !currentLocation.startsWith('/login') &&
          !currentLocation.startsWith('/register') &&
          currentLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      // If not logged in and trying to access protected routes
      if (!isLoggedIn && _isProtectedRoute(currentLocation)) {
        return AppRoutes.login;
      }

      // If logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && _isAuthRoute(currentLocation)) {
        return AppRoutes.home;
      }

      return null; // No redirect needed
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes with Shell Navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          // Home
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Tests
          GoRoute(
            path: AppRoutes.tests,
            name: 'tests',
            builder: (context, state) => const TestsScreen(),
          ),

          // History
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),

          // Chapters
          GoRoute(
            path: AppRoutes.chapters,
            name: 'chapters',
            builder: (context, state) => const ChaptersScreen(),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Detailed Routes (without bottom navigation)
      GoRoute(
        path: AppRoutes.testDetail,
        name: 'testDetail',
        builder: (context, state) {
          final testId = int.parse(state.pathParameters['testId']!);
          return TestDetailScreen(testId: testId);
        },
      ),

      GoRoute(
        path: AppRoutes.testTaking,
        name: 'testTaking',
        builder: (context, state) {
          final testId = int.parse(state.pathParameters['testId']!);
          final attemptId = int.tryParse(state.uri.queryParameters['attemptId'] ?? '');
          return TestTakingScreen(testId: testId, attemptId: attemptId);
        },
      ),

      GoRoute(
        path: AppRoutes.testResult,
        name: 'testResult',
        builder: (context, state) {
          final testId = int.parse(state.pathParameters['testId']!);
          final attemptId = int.parse(state.pathParameters['attemptId']!);
          return TestResultScreen(testId: testId, attemptId: attemptId);
        },
      ),

      GoRoute(
        path: AppRoutes.attemptDetail,
        name: 'attemptDetail',
        builder: (context, state) {
          final attemptId = int.parse(state.pathParameters['attemptId']!);
          return AttemptDetailScreen(attemptId: attemptId);
        },
      ),

      GoRoute(
        path: AppRoutes.chapterDetail,
        name: 'chapterDetail',
        builder: (context, state) {
          final chapterId = int.parse(state.pathParameters['chapterId']!);
          return ChapterDetailScreen(chapterId: chapterId);
        },
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.premium,
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

/// Helper functions for route checking
bool _isProtectedRoute(String location) {
  const protectedRoutes = [
    '/home',
    '/tests',
    '/history',
    '/profile',
    '/settings',
    '/premium',
    '/chapters',
  ];

  return protectedRoutes.any((route) => location.startsWith(route));
}

bool _isAuthRoute(String location) {
  const authRoutes = ['/login', '/register', '/onboarding'];
  return authRoutes.any((route) => location.startsWith(route));
}

/// Main Navigation Screen with Bottom Navigation
class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      route: AppRoutes.tests,
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz,
      label: 'Tests',
    ),
    NavigationItem(
      route: AppRoutes.chapters,
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'Chapters',
    ),
    NavigationItem(
      route: AppRoutes.history,
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'History',
    ),
    NavigationItem(
      route: AppRoutes.profile,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(_navigationItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final currentLocation = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _navigationItems.length; i++) {
      if (currentLocation.startsWith(_navigationItems[i].route)) {
        if (_selectedIndex != i) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedIndex = i;
              });
            }
          });
        }
        break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == _selectedIndex;
            return BottomNavigationBarItem(
              icon: Icon(isSelected ? item.selectedIcon : item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Navigation Item Model
class NavigationItem {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Error Screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({
    super.key,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}