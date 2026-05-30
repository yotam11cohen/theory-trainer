import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/achievement.dart';
import 'package:cleared_driving/features/profile/widgets/achievement_badge.dart';

void main() {
  group('AchievementBadge', () {
    testWidgets('earned badge has full opacity', (tester) async {
      final earned = Achievement(
        id: '1', name: 'First Lesson', description: 'Complete lesson 1', icon: '⭐',
        earnedAt: DateTime(2026, 5, 1),
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AchievementBadge(achievement: earned))),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });

    testWidgets('locked badge has reduced opacity', (tester) async {
      final locked = Achievement(
        id: '2', name: 'Level 5', description: 'Reach level 5', icon: '🏆',
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AchievementBadge(achievement: locked))),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.3);
    });

    testWidgets('shows achievement name', (tester) async {
      final a = Achievement(id: '1', name: 'Speed Star', description: '...', icon: '🌟');
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AchievementBadge(achievement: a))),
      );
      expect(find.text('Speed Star'), findsOneWidget);
    });

    testWidgets('shows achievement icon', (tester) async {
      final a = Achievement(id: '1', name: 'Test', description: '...', icon: '🏅');
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AchievementBadge(achievement: a))),
      );
      expect(find.text('🏅'), findsOneWidget);
    });
  });
}
