import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/dashboard/screens/home_screen.dart';
import 'features/learn/screens/category_list_screen.dart';
import 'features/learn/screens/lesson_list_screen.dart';
import 'features/learn/screens/exercise_player_screen.dart';
import 'features/exam/screens/exam_intro_screen.dart';
import 'features/exam/screens/exam_session_screen.dart';
import 'features/exam/screens/exam_result_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/leaderboard/screens/leaderboard_screen.dart';
import 'shared/widgets/bottom_nav_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);
  ref.onDispose(authNotifier.dispose);

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
    // Only update once the stream has emitted (skip loading state)
    next.whenData((authState) {
      authNotifier.value = authState.session != null;
    });
  });

  return GoRouter(
    initialLocation: '/app/home',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // While auth stream hasn't emitted yet, don't redirect
      final authAsync = ref.read(authStateProvider);
      if (authAsync is AsyncLoading) return null;

      final loggedIn = authNotifier.value;
      final onAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/app/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => BottomNavShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/app/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/learn',
              builder: (_, __) => const CategoryListScreen(),
              routes: [
                GoRoute(
                  path: ':category',
                  builder: (_, s) => LessonListScreen(
                      category: s.pathParameters['category']!),
                  routes: [
                    GoRoute(
                      path: ':lessonId',
                      builder: (_, s) => ExercisePlayerScreen(
                          lessonId: s.pathParameters['lessonId']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/exam',
              builder: (_, __) => const ExamIntroScreen(),
              routes: [
                GoRoute(
                    path: 'session',
                    builder: (_, __) => const ExamSessionScreen()),
                GoRoute(
                    path: 'result',
                    builder: (_, __) => const ExamResultScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/app/profile',
                builder: (_, __) => const ProfileScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/leaderboard',
              builder: (_, __) => const LeaderboardScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
