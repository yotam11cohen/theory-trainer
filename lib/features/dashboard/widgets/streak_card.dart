import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streakCount;
  const StreakCard({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakCount',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text('Day Streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
