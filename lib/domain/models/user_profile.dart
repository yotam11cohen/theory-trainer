class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final int totalXp;
  final int level;
  final int streakCount;
  final DateTime? lastActive;
  final bool notificationsEnabled;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.totalXp,
    required this.level,
    required this.streakCount,
    this.lastActive,
    required this.notificationsEnabled,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        totalXp: json['total_xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        streakCount: json['streak_count'] as int? ?? 0,
        lastActive: json['last_active'] != null
            ? DateTime.tryParse(json['last_active'] as String)
            : null,
        notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      );

  UserProfile copyWith({
    int? totalXp,
    int? level,
    int? streakCount,
    DateTime? lastActive,
    bool? notificationsEnabled,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName,
        avatarUrl: avatarUrl,
        totalXp: totalXp ?? this.totalXp,
        level: level ?? this.level,
        streakCount: streakCount ?? this.streakCount,
        lastActive: lastActive ?? this.lastActive,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}
