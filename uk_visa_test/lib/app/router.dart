// lib/app/router.dart - UPDATED WITH REVIEW ANSWERS ROUTE
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/states/AuthState.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/chapters/screens/chapter_reading_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/tests/screens/test_list_screen.dart';
import '../features/tests/screens/test_detail_screen.dart';
import '../features/tests/screens/test_taking_screen.dart';
import '../features/tests/screens/test_result_screen.dart';
import '../features/tests/screens/review_answers_screen.dart';
import '../features/chapters/screens/chapter_list_screen.dart';
import '../features/chapters/screens/chapter_detail_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../shared/widgets/main_navigation.dart';

// ✅ Create a separate provider for router that can access auth state
final routerProvider = Provider<GoRouter>((ref) {
  // Create a notifier to listen to auth changes
  final authNotifier = ValueNotifier<AsyncValue<AuthState>>(
      AsyncValue.data(ref.read(authProvider))
  );

  // Listen to auth changes and update the notifier
  ref.listen(authProvider, (previous, next) {
    print('🔄 Router: Auth state changed - wasAuth: ${previous?.isAuthenticated}, nowAuth: ${next.isAuthenticated}');
    authNotifier.value = AsyncValue.data(next);
  });

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated && authState.user != null;
      final isLoggingIn = state.fullPath == '/login' || state.fullPath == '/register';
      final currentLocation = state.fullPath;

      print('🔄 Router Redirect Check:');
      print('   📍 Current location: $currentLocation');
      print('   🔐 Is logged in: $isLoggedIn');
      print('   👤 User: ${authState.user?.email ?? 'null'}');
      print('   🔄 Is auth screen: $isLoggingIn');
      print('   ⏳ Is loading: ${authState.isLoading}');

      if (authState.isLoading) {
        print('   ⏳ Auth is loading, no redirect');
        return null;
      }

      if (!isLoggedIn && !isLoggingIn) {
        print('   ➡️ Redirecting to login (not authenticated)');
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        print('   ➡️ Redirecting to home (already authenticated)');
        return '/';
      }

      print('   ✅ No redirect needed');
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          print('🏗️ Building LoginScreen');
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          print('🏗️ Building RegisterScreen');
          return const RegisterScreen();
        },
      ),

      // Main Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          print('🏗️ Building MainNavigation shell for: ${state.fullPath}');
          return MainNavigation(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) {
              print('🏗️ Building HomeScreen');
              return const HomeScreen();
            },
          ),

          // Tests
          GoRoute(
            path: '/tests',
            name: 'tests',
            builder: (context, state) {
              print('🏗️ Building TestListScreen');
              return const TestListScreen();
            },
            routes: [
              GoRoute(
                path: ':id',
                name: 'test-detail',
                builder: (context, state) {
                  // ✅ Safe ID parsing with detailed error handling
                  final idParam = state.pathParameters['id'];
                  print('🔍 Test detail route - Raw ID param: "$idParam"');

                  if (idParam == null || idParam.isEmpty) {
                    print('❌ Missing test ID parameter');
                    return _buildErrorScreen('Missing test ID');
                  }

                  // ✅ Check if it looks like an object string representation
                  if (idParam.contains('(') || idParam.contains('TestAttempt') || idParam.contains('Test(')) {
                    print('❌ Invalid ID parameter - looks like object: $idParam');
                    return _buildErrorScreen('Invalid test ID format: ${idParam.substring(0, 50)}...');
                  }

                  final id = int.tryParse(idParam);
                  if (id == null) {
                    print('❌ Invalid test ID - cannot parse: "$idParam"');
                    return _buildErrorScreen('Invalid test ID: $idParam');
                  }

                  print('🏗️ Building TestDetailScreen for test: $id');
                  return TestDetailScreen(testId: id);
                },
                routes: [
                  GoRoute(
                    path: 'take',
                    name: 'test-taking',
                    builder: (context, state) {
                      // ✅ Safe parsing for test taking
                      final idParam = state.pathParameters['id'];
                      final attemptIdParam = state.uri.queryParameters['attemptId'];

                      print('🔍 Test taking route - Test ID: "$idParam", Attempt ID: "$attemptIdParam"');

                      if (idParam == null || idParam.isEmpty) {
                        print('❌ Missing test ID for test taking');
                        return _buildErrorScreen('Missing test ID');
                      }

                      // Check for object strings
                      if (idParam.contains('(') || idParam.contains('Test')) {
                        print('❌ Invalid test ID for taking - looks like object: $idParam');
                        return _buildErrorScreen('Invalid test ID format');
                      }

                      final id = int.tryParse(idParam);
                      if (id == null) {
                        print('❌ Invalid test ID for taking: "$idParam"');
                        return _buildErrorScreen('Invalid test ID: $idParam');
                      }

                      // ✅ Safe parsing for attempt ID (optional)
                      int? attemptId;
                      if (attemptIdParam != null && attemptIdParam.isNotEmpty) {
                        if (attemptIdParam.contains('(') || attemptIdParam.contains('TestAttempt')) {
                          print('❌ Invalid attempt ID - looks like object: $attemptIdParam');
                          return _buildErrorScreen('Invalid attempt ID format');
                        }
                        attemptId = int.tryParse(attemptIdParam);
                        if (attemptId == null) {
                          print('❌ Invalid attempt ID: "$attemptIdParam"');
                          return _buildErrorScreen('Invalid attempt ID: $attemptIdParam');
                        }
                      }

                      print('🏗️ Building TestTakingScreen - Test: $id, Attempt: $attemptId');
                      return TestTakingScreen(testId: id, attemptId: attemptId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'result/:attemptId',
                name: 'test-result',
                builder: (context, state) {
                  // ✅ Safe parsing for test results
                  final attemptIdParam = state.pathParameters['attemptId'];
                  print('🔍 Test result route - Attempt ID: "$attemptIdParam"');

                  if (attemptIdParam == null || attemptIdParam.isEmpty) {
                    print('❌ Missing attempt ID for results');
                    return _buildErrorScreen('Missing attempt ID');
                  }

                  // ✅ Check for object strings
                  if (attemptIdParam.contains('(') ||
                      attemptIdParam.contains('TestAttempt') ||
                      attemptIdParam.contains('Object') ||
                      attemptIdParam.length > 20) {
                    print('❌ Invalid attempt ID - looks like object representation:');
                    print('   Full string: $attemptIdParam');
                    return _buildErrorScreen('Invalid attempt ID format. Expected number, got object.');
                  }

                  final attemptId = int.tryParse(attemptIdParam);
                  if (attemptId == null) {
                    print('❌ Invalid attempt ID - cannot parse: "$attemptIdParam"');
                    return _buildErrorScreen('Invalid attempt ID: $attemptIdParam');
                  }

                  print('🏗️ Building TestResultScreen for attempt: $attemptId');
                  return TestResultScreen(attemptId: attemptId);
                },
                routes: [
                  // ✅ NEW: Review Answers Route
                  GoRoute(
                    path: 'review',
                    name: 'review-answers',
                    builder: (context, state) {
                      final attemptIdParam = state.pathParameters['attemptId'];
                      print('🔍 Review answers route - Attempt ID: "$attemptIdParam"');

                      if (attemptIdParam == null || attemptIdParam.isEmpty) {
                        return _buildErrorScreen('Missing attempt ID for review');
                      }

                      if (attemptIdParam.contains('(') || attemptIdParam.contains('TestAttempt')) {
                        return _buildErrorScreen('Invalid attempt ID format for review');
                      }

                      final attemptId = int.tryParse(attemptIdParam);
                      if (attemptId == null) {
                        return _buildErrorScreen('Invalid attempt ID for review: $attemptIdParam');
                      }

                      print('🏗️ Building ReviewAnswersScreen for attempt: $attemptId');
                      return ReviewAnswersScreen(attemptId: attemptId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Chapters
          GoRoute(
            path: '/chapters',
            name: 'chapters',
            builder: (context, state) {
              print('🏗️ Building ChapterListScreen');
              return const ChapterListScreen();
            },
            routes: [
              GoRoute(
                path: ':id',
                name: 'chapter-detail',
                builder: (context, state) {
                  // ✅ Safe parsing for chapter detail
                  final idParam = state.pathParameters['id'];
                  print('🔍 Chapter detail route - ID: "$idParam"');

                  if (idParam == null || idParam.isEmpty) {
                    return _buildErrorScreen('Missing chapter ID');
                  }

                  if (idParam.contains('(') || idParam.contains('Chapter')) {
                    return _buildErrorScreen('Invalid chapter ID format');
                  }

                  final id = int.tryParse(idParam);
                  if (id == null) {
                    return _buildErrorScreen('Invalid chapter ID: $idParam');
                  }

                  print('🏗️ Building ChapterDetailScreen for chapter: $id');
                  return ChapterDetailScreen(chapterId: id);
                },
                routes: [
                  GoRoute(
                    path: 'read',
                    name: 'chapter-reading',
                    builder: (context, state) {
                      final idParam = state.pathParameters['id'];

                      if (idParam == null || idParam.isEmpty) {
                        return _buildErrorScreen('Missing chapter ID');
                      }

                      final id = int.tryParse(idParam);
                      if (id == null) {
                        return _buildErrorScreen('Invalid chapter ID: $idParam');
                      }

                      print('🏗️ Building ChapterReadingScreen for chapter: $id');
                      return ChapterReadingScreen(chapterId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Progress
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) {
              print('🏗️ Building ProgressScreen');
              return const ProgressScreen();
            },
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) {
              print('🏗️ Building SettingsScreen');
              return const SettingsScreen();
            },
            routes: [
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) {
                  print('🏗️ Building ProfileScreen');
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
    // ✅ Enhanced error handling
    errorBuilder: (context, state) {
      print('❌ Router Error: ${state.error}');
      print('❌ Error Location: ${state.fullPath}');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Navigation Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${state.fullPath}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${state.error}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

// ✅ Helper function to build error screens
Widget _buildErrorScreen(String message) => Builder(
  builder: (context) => Scaffold(
    appBar: AppBar(
      title: const Text('Invalid Route'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Invalid Route Parameter',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    ),
  ),
);