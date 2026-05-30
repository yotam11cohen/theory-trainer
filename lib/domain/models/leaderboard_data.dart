import 'leaderboard_entry.dart';

class LeaderboardData {
  final List<LeaderboardEntry> top50;
  final String currentUserId;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardData({
    required this.top50,
    required this.currentUserId,
    required this.currentUserEntry,
  });
}
