import 'leaderboard_entry.dart';

class LeaderboardData {
  final List<LeaderboardEntry> topEntries;
  final String currentUserId;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardData({
    required this.topEntries,
    required this.currentUserId,
    this.currentUserEntry,
  });
}
