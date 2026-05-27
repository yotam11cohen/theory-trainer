import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/data/remote/exam_service.dart';
import 'package:cleared_driving/domain/models/driving_exercise.dart';

void main() {
  test('buildExam returns 30 questions from large pool', () {
    final pool = _makePool({
      'signs': 20,
      'safe_driving': 15,
      'laws': 12,
      'mechanics': 8,
      'first_aid': 8,
    });

    final exam = ExamService.buildExam(pool);
    expect(exam.length, 30);
    expect(exam.map((e) => e.id).toSet().length, 30); // no duplicates
  });

  test('buildExam throws StateError when pool is empty', () {
    expect(() => ExamService.buildExam([]), throwsStateError);
  });

  test('buildExam returns all questions when pool has fewer than 30', () {
    final pool = _makePool({'signs': 5, 'safe_driving': 3});
    final exam = ExamService.buildExam(pool);
    expect(exam.length, lessThanOrEqualTo(30));
    expect(exam.map((e) => e.id).toSet().length, exam.length); // no duplicates
  });
}

List<DrivingExercise> _makePool(Map<String, int> categoryCounts) {
  var id = 0;
  final pool = <DrivingExercise>[];
  for (final entry in categoryCounts.entries) {
    for (var i = 0; i < entry.value; i++) {
      pool.add(DrivingExercise(
        id: '${id++}',
        lessonId: 'l1',
        orderIndex: i,
        type: ExerciseType.vocabulary,
        isExamQuestion: true,
        content: {
          'category': entry.key,
          'term': 'x',
          'definition': 'y',
        },
      ));
    }
  }
  return pool;
}
