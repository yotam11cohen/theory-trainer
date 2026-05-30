import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/achievement.dart';

void main() {
  group('Achievement.isEarned', () {
    test('true when earnedAt is set', () {
      final a = Achievement(
        id: '1', name: 'First', description: 'desc', icon: '🏆',
        earnedAt: DateTime(2026, 1, 1),
      );
      expect(a.isEarned, true);
    });

    test('false when earnedAt is null', () {
      final a = Achievement(
        id: '2', name: 'Locked', description: 'desc', icon: '🎖️',
      );
      expect(a.isEarned, false);
    });
  });

  group('Achievement.fromJson', () {
    test('parses earned_at as DateTime', () {
      final a = Achievement.fromJson({
        'id': '1',
        'name': 'First Lesson',
        'description': 'Complete your first lesson',
        'icon': '⭐',
        'earned_at': '2026-05-30T10:00:00.000Z',
      });
      expect(a.isEarned, true);
      expect(a.earnedAt, isNotNull);
    });

    test('earned_at null when missing', () {
      final a = Achievement.fromJson({
        'id': '2',
        'name': 'Level 5',
        'description': 'Reach level 5',
        'icon': '🏅',
      });
      expect(a.isEarned, false);
      expect(a.earnedAt, isNull);
    });
  });
}
