import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/leaderboard_data.dart';
import '../domain/models/leaderboard_entry.dart';
import 'auth_provider.dart';
import 'supabase_provider.dart';
import 'user_provider.dart';

final leaderboardProvider = FutureProvider<LeaderboardData>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const LeaderboardData(topEntries: [], currentUserId: '');
  }

  final profile = ref.watch(userProfileProvider).valueOrNull;
  final service = ref.watch(supabaseServiceProvider);

  final topEntries = await service.fetchLeaderboard();
  final inTop = topEntries.any((e) => e.userId == user.id);

  LeaderboardEntry? currentUserEntry;
  if (!inTop && profile != null) {
    final rank = await service.fetchUserRank(profile.totalXp);
    currentUserEntry = LeaderboardEntry(
      rank: rank,
      userId: user.id,
      displayName: profile.displayName,
      totalXp: profile.totalXp,
    );
  }

  return LeaderboardData(
    topEntries: topEntries,
    currentUserId: user.id,
    currentUserEntry: currentUserEntry,
  );
});
