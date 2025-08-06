import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/tests/screens/test_list_screen.dart';
import '../features/tests/screens/test_detail_screen.dart';
import '../features/tests/screens/test_taking_screen.dart';
import '../features/tests/screens/test_result_screen.dart';
import '../features/chapters/screens/chapter_list_screen.dart';
import '../features/chapters/screens/chapter_detail_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../shared/widgets/main_navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.fullPath == '/login' || state.fullPath == '/register';

      // If not logged in and not on auth screens, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on auth screens, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Tests - FIXED: Nested routes without leading "/"
          GoRoute(
            path: '/tests',
            name: 'tests',
            builder: (context, state) => const TestListScreen(),
            routes: [
              GoRoute(
                path: ':id', // FIXED: Removed leading "/"
                name: 'test-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return TestDetailScreen(testId: id);
                },
                routes: [
                  GoRoute(
                    path: 'take', // FIXED: Removed leading "/"
                    name: 'test-taking',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final attemptId = int.tryParse(state.uri.queryParameters['attemptId'] ?? '');
                      return TestTakingScreen(testId: id, attemptId: attemptId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'result/:attemptId', // FIXED: Removed leading "/"
                name: 'test-result',
                builder: (context, state) {
                  final attemptId = int.parse(state.pathParameters['attemptId']!);
                  return TestResultScreen(attemptId: attemptId);
                },
              ),
            ],
          ),

          // Chapters - FIXED: Nested routes without leading "/"
          GoRoute(
            path: '/chapters',
            name: 'chapters',
            builder: (context, state) => const ChapterListScreen(),
            routes: [
              GoRoute(
                path: ':id', // FIXED: Removed leading "/"
                name: 'chapter-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return ChapterDetailScreen(chapterId: id);
                },
              ),
            ],
          ),

          // Progress
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),

          // Settings - FIXED: Nested routes without leading "/"
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile', // FIXED: Removed leading "/"
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});