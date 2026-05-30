import 'package:flutter/material.dart';
import '../../../domain/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const AchievementBadge({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: achievement.isEarned ? 1.0 : 0.55,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
