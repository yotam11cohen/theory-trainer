import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/lessons_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/supabase_provider.dart';
import '../../../data/local/hive_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/xp_bar.dart';
import '../../../shared/notifications.dart';

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
          // Flush offline progress queue and schedule reminders after frame (fire-and-forget, non-critical)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final user = ref.read(currentUserProvider);
            if (user != null) {
              ref.read(supabaseServiceProvider).flushProgressQueue(user.id);
            }
            NotificationScheduler.scheduleRemindersIfNeeded(profile.lastActive);
          });
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StreakCard(streakCount: profile.streakCount),
              const SizedBox(height: 12),
              XpBar(totalXp: profile.totalXp, level: profile.level),
              const SizedBox(height: 20),
              lessonsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
                data: (lessons) {
                  if (lessons.isEmpty) return const SizedBox.shrink();
                  final completed = HiveService.getCompletedLessonIds();
                  final next = lessons.firstWhere(
                    (l) => !completed.contains(l.id),
                    orElse: () => lessons.first,
                  );
                  return ElevatedButton.icon(
                    onPressed: () => context.push(
                        '/app/learn/${next.category}/${next.id}'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Continue Studying'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
