import 'package:flutter/material.dart';
import '../../../domain/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const AchievementBadge({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earned = achievement.isEarned;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: earned
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Text(
            achievement.icon,
            style: TextStyle(fontSize: 24, color: earned ? null : Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            achievement.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight:
                      earned ? FontWeight.bold : FontWeight.normal,
                  color: earned
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.45),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
