class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final int totalXp;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalXp,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {required int rank}) =>
      LeaderboardEntry(
        rank: rank,
        userId: json['id'] as String,
        displayName: json['display_name'] as String? ?? '',
        totalXp: json['total_xp'] as int? ?? 0,
      );
}
