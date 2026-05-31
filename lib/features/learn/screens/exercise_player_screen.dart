import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/lessons_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/supabase_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/leaderboard_provider.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/local/models/progress_event.dart';
import '../../../domain/xp.dart';
import '../../../shared/in_app_banner.dart';
import '../../../shared/sound_service.dart';
import '../widgets/exercise_shell.dart';

class ExercisePlayerScreen extends ConsumerWidget {
  final String lessonId;
  const ExercisePlayerScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(child: Text('No exercises in this lesson.'));
          }
          return ExerciseShell(
            exercises: exercises,
            onComplete: (score) async {
              SoundService.playSuccess();
              final user = ref.read(currentUserProvider);
              final service = ref.read(supabaseServiceProvider);
              final profile = ref.read(userProfileProvider).valueOrNull;
              final completed = ref.read(completedLessonsProvider).valueOrNull ?? {};
              final isFirst = completed.isEmpty;
              final oldLevel = XpCalculator.levelFor(profile?.totalXp ?? 0);
              final newLevel = XpCalculator.levelFor(
                  (profile?.totalXp ?? 0) + XpCalculator.xpForScore(score));

              try {
                if (user != null) {
                  await service.recordProgress(
                    userId: user.id,
                    lessonId: lessonId,
                    score: score,
                  );
                  ref.invalidate(userProfileProvider);
                  ref.invalidate(leaderboardProvider);
                }
              } catch (_) {
                await HiveService.enqueueProgress(ProgressEvent(
                  lessonId: lessonId,
                  score: score,
                  earnedAt: DateTime.now(),
                ));
                await HiveService.markLessonComplete(lessonId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved offline — will sync when connected'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }

              if (context.mounted) {
                if (isFirst) {
                  InAppBanner.show(context,
                      emoji: '⭐', message: 'Great start! First lesson complete!');
                } else if (newLevel > oldLevel) {
                  InAppBanner.show(context,
                      emoji: '🎉',
                      message: 'Level up! You are now ${XpCalculator.levelTitle(newLevel)} — ${XpCalculator.levelDescription(newLevel)}');
                }
                context.pop();
              }
            },
          );
        },
      ),
    );
  }
}
