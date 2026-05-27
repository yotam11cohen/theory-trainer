import 'dart:math';
import '../../domain/models/driving_exercise.dart';
import '../../constants.dart';

abstract class ExamService {
  static List<DrivingExercise> buildExam(List<DrivingExercise> pool) {
    if (pool.isEmpty) throw StateError('Exam pool is empty');

    final byCategory = <String, List<DrivingExercise>>{};
    for (final ex in pool) {
      final cat = ex.content['category'] as String? ?? 'signs';
      byCategory.putIfAbsent(cat, () => []).add(ex);
    }

    const weights = AppConstants.categoryWeights;
    const total = AppConstants.examQuestionCount;
    final rng = Random();
    final selected = <DrivingExercise>[];

    for (final entry in weights.entries) {
      final count = (total * entry.value).round();
      final available = List<DrivingExercise>.from(
        byCategory[entry.key] ?? [],
      )..shuffle(rng);
      selected.addAll(available.take(count));
    }

    // Fill remaining slots if rounding left gaps
    final remaining = pool
        .where((e) => !selected.contains(e))
        .toList()
      ..shuffle(rng);
    while (selected.length < total && remaining.isNotEmpty) {
      selected.add(remaining.removeLast());
    }

    selected.shuffle(rng);
    assert(selected.length >= total || pool.length < total,
        'buildExam produced only ${selected.length} questions from a ${pool.length}-item pool');
    return selected.take(total).toList();
  }
}
