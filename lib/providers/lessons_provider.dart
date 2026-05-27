import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/driving_lesson.dart';
import '../domain/models/driving_exercise.dart';
import 'supabase_provider.dart';

final lessonsProvider = FutureProvider<List<DrivingLesson>>((ref) async {
  return ref.watch(supabaseServiceProvider).fetchLessons();
});

final exercisesProvider =
    FutureProvider.family<List<DrivingExercise>, String>((ref, lessonId) async {
  return ref.watch(supabaseServiceProvider).fetchExercisesForLesson(lessonId);
});
