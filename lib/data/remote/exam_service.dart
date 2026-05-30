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

    final weights = AppConstants.categoryWeights;
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

    // Deduplicate by question text — catches DB rows with identical content but different IDs
    final seen = <String>{};
    final deduped = selected.where((e) {
      final key = e.content['question'] as String? ??
          e.content['text'] as String? ??
          e.content['term'] as String? ??
          e.id;
      return seen.add(key);
    }).toList()
      ..shuffle(rng);

    assert(deduped.length >= total || pool.length < total,
        'buildExam produced only ${deduped.length} questions from a ${pool.length}-item pool');
    return deduped.take(total).toList();
  }
}
