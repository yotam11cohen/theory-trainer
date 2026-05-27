import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/lessons_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/supabase_provider.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/local/models/progress_event.dart';
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
              final user = ref.read(currentUserProvider);
              final service = ref.read(supabaseServiceProvider);

              try {
                if (user != null) {
                  await service.recordProgress(
                    userId: user.id,
                    lessonId: lessonId,
                    score: score,
                  );
                }
              } catch (_) {
                // Queue offline
                await HiveService.enqueueProgress(ProgressEvent(
                  lessonId: lessonId,
                  score: score,
                  earnedAt: DateTime.now(),
                ));
                await HiveService.markLessonComplete(lessonId);
              }

              if (context.mounted) context.pop();
            },
          );
        },
      ),
    );
  }
}
