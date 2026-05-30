import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/user_profile.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('parses all fields', () {
      final profile = UserProfile.fromJson({
        'id': 'u1',
        'display_name': 'Yotam',
        'avatar_url': 'https://example.com/avatar.png',
        'total_xp': 750,
        'level': 2,
        'streak_count': 5,
        'last_active': '2026-05-29',
        'notifications_enabled': false,
      });
      expect(profile.id, 'u1');
      expect(profile.displayName, 'Yotam');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
      expect(profile.totalXp, 750);
      expect(profile.level, 2);
      expect(profile.streakCount, 5);
      expect(profile.lastActive, DateTime(2026, 5, 29));
      expect(profile.notificationsEnabled, false);
    });

    test('uses defaults for missing nullable fields', () {
      final profile = UserProfile.fromJson({'id': 'u2'});
      expect(profile.displayName, '');
      expect(profile.avatarUrl, isNull);
      expect(profile.totalXp, 0);
      expect(profile.level, 1);
      expect(profile.streakCount, 0);
      expect(profile.lastActive, isNull);
      expect(profile.notificationsEnabled, true);
    });
  });

  group('UserProfile.copyWith', () {
    late UserProfile base;

    setUp(() {
      base = const UserProfile(
        id: 'u1',
        displayName: 'Yotam',
        totalXp: 500,
        level: 2,
        streakCount: 3,
        notificationsEnabled: true,
      );
    });

    test('updates totalXp and level, preserves rest', () {
      final updated = base.copyWith(totalXp: 1500, level: 3);
      expect(updated.totalXp, 1500);
      expect(updated.level, 3);
      expect(updated.id, 'u1');
      expect(updated.displayName, 'Yotam');
      expect(updated.streakCount, 3);
    });

    test('can set lastActive to a date', () {
      final date = DateTime(2026, 5, 30);
      final updated = base.copyWith(lastActive: date);
      expect(updated.lastActive, date);
    });

    test('can explicitly set lastActive to null', () {
      final withDate = base.copyWith(lastActive: DateTime(2026, 5, 30));
      final cleared = withDate.copyWith(lastActive: null);
      expect(cleared.lastActive, isNull);
    });

    test('omitting lastActive preserves existing value', () {
      final withDate = base.copyWith(lastActive: DateTime(2026, 5, 30));
      final updated = withDate.copyWith(streakCount: 10);
      expect(updated.lastActive, DateTime(2026, 5, 30));
    });
  });
}
