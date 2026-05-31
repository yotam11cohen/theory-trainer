import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/leaderboard_entry.dart';
import '../../../domain/xp.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.tabLeaderboard)),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load leaderboard'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(leaderboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final pinnedEntry = data.currentUserEntry;
          final highlight =
              Theme.of(context).colorScheme.primary.withOpacity(0.10);

          return ListView.builder(
            itemCount: data.topEntries.length + (pinnedEntry != null ? 2 : 0),
            itemBuilder: (context, index) {
              if (index < data.topEntries.length) {
                final entry = data.topEntries[index];
                return _LeaderboardTile(
                  entry: entry,
                  highlight: entry.userId == data.currentUserId ? highlight : null,
                );
              }
              if (index == data.topEntries.length) return const Divider();
              return _LeaderboardTile(entry: pinnedEntry!, highlight: highlight);
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final Color? highlight;

  const _LeaderboardTile({required this.entry, this.highlight});

  @override
  Widget build(BuildContext context) {
    final level = XpCalculator.levelFor(entry.totalXp);
    final title = XpCalculator.levelTitle(level);
    final description = XpCalculator.levelDescription(level);
    return ListTile(
      tileColor: highlight,
      leading: SizedBox(
        width: 36,
        child: Text(
          '#${entry.rank}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(entry.displayName),
      subtitle: Text(
        '$title · $description',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Text(
        '${entry.totalXp} XP',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
