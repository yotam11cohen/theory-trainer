import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/lessons_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/supabase_provider.dart';
import '../../../domain/models/driving_lesson.dart';
import '../../../domain/xp.dart';
import '../../../data/local/hive_service.dart';
import '../../../constants.dart';
import '../../../shared/notifications.dart';
import '../widgets/streak_card.dart';
import '../widgets/xp_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final lessonsAsync = ref.watch(lessonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cleared')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Not logged in'));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final user = ref.read(currentUserProvider);
            if (user != null) {
              ref.read(supabaseServiceProvider).flushProgressQueue(user.id);
            }
            NotificationScheduler.scheduleRemindersIfNeeded(profile.lastActive);
          });

          return lessonsAsync.when(
            loading: () => _buildContent(context, profile, [], {}),
            error: (_, __) => _buildContent(context, profile, [], {}),
            data: (lessons) {
              final completed = HiveService.getCompletedLessonIds();
              return _buildContent(context, profile, lessons, completed, ref: ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic profile,
    List<DrivingLesson> lessons,
    Set<String> completed, {
    WidgetRef? ref,
  }) {
    final total = lessons.length;
    final doneCount = completed.length.clamp(0, total == 0 ? 0 : total);
    final pct = total == 0 ? 0 : ((doneCount / total) * 100).round();
    final title = XpCalculator.levelTitle(profile.level);

    // Find next lesson
    final sortedLessons = [...lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final nextLesson = sortedLessons.firstWhere(
      (l) => !completed.contains(l.id),
      orElse: () => sortedLessons.isEmpty ? null as DrivingLesson : sortedLessons.last,
    );
    final allDone = total > 0 && doneCount >= total;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StreakCard(streakCount: profile.streakCount),
        const SizedBox(height: 12),
        XpBar(totalXp: profile.totalXp, level: profile.level),
        const SizedBox(height: 20),

        // Summary stats row
        Row(
          children: [
            _StatChip(label: '$doneCount lessons done', icon: Icons.check_circle_outline),
            const SizedBox(width: 8),
            _StatChip(label: '$pct% complete', icon: Icons.bar_chart),
            const SizedBox(width: 8),
            _StatChip(label: 'Lv${profile.level} $title', icon: Icons.star_outline),
          ],
        ),
        const SizedBox(height: 24),

        // Category breakdown
        Text('Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...AppConstants.categories.map((cat) {
          final catLessons = lessons.where((l) => l.category == cat.slug).toList();
          final catDone = catLessons.where((l) => completed.contains(l.id)).length;
          final catTotal = catLessons.length;
          final catProgress = catTotal == 0 ? 0.0 : catDone / catTotal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(cat.icon, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.nameHe,
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('$catDone/$catTotal',
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: catProgress,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),

        // Continue button
        if (total > 0)
          ElevatedButton.icon(
            onPressed: allDone
                ? () => context.push('/app/exam')
                : () => context.push(
                    '/app/learn/${nextLesson.category}/${nextLesson.id}'),
            icon: Icon(allDone ? Icons.quiz_outlined : Icons.play_arrow),
            label: Text(
              allDone
                  ? 'Take the Exam →'
                  : 'Continue: ${_categoryName(nextLesson.category)} — ${nextLesson.title}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  String _categoryName(String slug) {
    final cat = AppConstants.categories.firstWhere(
      (c) => c.slug == slug,
      orElse: () => AppConstants.categories.first,
    );
    return cat.nameHe;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
