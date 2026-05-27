import 'package:flutter/material.dart';
import '../../../domain/xp.dart';

class XpBar extends StatelessWidget {
  final int totalXp;
  final int level;
  const XpBar({super.key, required this.totalXp, required this.level});

  @override
  Widget build(BuildContext context) {
    final progress = XpCalculator.progressToNext(totalXp, level);
    final next = XpCalculator.nextThreshold(level);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level $level',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              next != null ? '$totalXp / $next XP' : '$totalXp XP — Max Level',
            ),
          ],
        ),
      ),
    );
  }
}
