import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry.fromJson', () {
    test('parses all fields correctly', () {
      final entry = LeaderboardEntry.fromJson(
        {'id': 'u1', 'display_name': 'Alice', 'total_xp': 1250},
        rank: 3,
      );
      expect(entry.rank, 3);
      expect(entry.userId, 'u1');
      expect(entry.displayName, 'Alice');
      expect(entry.totalXp, 1250);
    });

    test('defaults display_name to empty string when absent', () {
      final entry = LeaderboardEntry.fromJson(
        {'id': 'u1', 'total_xp': 500},
        rank: 1,
      );
      expect(entry.displayName, '');
    });

    test('defaults total_xp to 0 when absent', () {
      final entry = LeaderboardEntry.fromJson(
        {'id': 'u1', 'display_name': 'Bob'},
        rank: 2,
      );
      expect(entry.totalXp, 0);
    });
  });
}
