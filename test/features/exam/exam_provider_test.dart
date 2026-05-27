import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/providers/exam_provider.dart';
import 'package:cleared_driving/domain/models/driving_exercise.dart';

void main() {
  test('ExamState score counts correct answers', () {
    final exercises = List.generate(
      3,
      (i) => DrivingExercise(
        id: '$i',
        lessonId: 'l',
        orderIndex: i,
        type: ExerciseType.vocabulary,
        isExamQuestion: true,
        content: {'correct_index': 0},
      ),
    );
    final state = ExamState(
      questions: exercises,
      currentIndex: 3,
      answers: {0: 0, 1: 1, 2: 0}, // 2 correct
      submitted: true,
    );
    expect(state.score, 2);
    expect(state.passed, false); // needs 26/30
  });
}
