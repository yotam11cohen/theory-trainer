import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/leaderboard_data.dart';
import 'package:cleared_driving/domain/models/leaderboard_entry.dart';
import 'package:cleared_driving/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:cleared_driving/l10n/app_localizations.dart';
import 'package:cleared_driving/providers/leaderboard_provider.dart';

LeaderboardEntry _e(int rank, String userId, String name, int xp) =>
    LeaderboardEntry(rank: rank, userId: userId, displayName: name, totalXp: xp);

/// Wraps the screen with a ProviderScope that overrides leaderboardProvider.
/// [makeOverride] receives the provider and returns an Override.
Widget _wrapWith(Override Function() makeOverride) => ProviderScope(
      overrides: [makeOverride()],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LeaderboardScreen(),
      ),
    );

Widget _wrapLoading() => _wrapWith(
      () => leaderboardProvider.overrideWith((_) => Completer<LeaderboardData>().future),
    );

Widget _wrapError() => _wrapWith(
      () => leaderboardProvider.overrideWith((_) => Future<LeaderboardData>.error(Exception('fail'))),
    );

Widget _wrapData(LeaderboardData data) => _wrapWith(
      () => leaderboardProvider.overrideWith((_) => Future.value(data)),
    );

void main() {
  group('LeaderboardScreen', () {
    testWidgets('shows loading spinner while loading', (tester) async {
      await tester.pumpWidget(_wrapLoading());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(_wrapError());
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders rank, name and XP for each entry', (tester) async {
      final data = LeaderboardData(
        topEntries: [_e(1, 'u1', 'Alice', 1500), _e(2, 'u2', 'Bob', 900)],
        currentUserId: 'other',
      );
      await tester.pumpWidget(_wrapData(data));
      await tester.pumpAndSettle();
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('1500 XP'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('900 XP'), findsOneWidget);
    });

    testWidgets('no divider or pinned row when current user is in top entries', (tester) async {
      final data = LeaderboardData(
        topEntries: [_e(1, 'me', 'Me', 2000)],
        currentUserId: 'me',
      );
      await tester.pumpWidget(_wrapData(data));
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('shows pinned row below divider when user is outside top entries', (tester) async {
      final data = LeaderboardData(
        topEntries: [_e(1, 'u1', 'Alice', 1500)],
        currentUserId: 'me',
        currentUserEntry: _e(42, 'me', 'Me', 200),
      );
      await tester.pumpWidget(_wrapData(data));
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('#42'), findsOneWidget);
      expect(find.text('200 XP'), findsOneWidget);
    });
  });
}
