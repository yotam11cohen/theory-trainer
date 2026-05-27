class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime? earnedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.earnedAt,
  });

  bool get isEarned => earnedAt != null;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        earnedAt: json['earned_at'] != null
            ? DateTime.tryParse(json['earned_at'] as String)
            : null,
      );
}
