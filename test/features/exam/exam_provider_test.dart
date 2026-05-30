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

  test('ExamState passed=true when score >= 26 out of 30', () {
    final exercises = List.generate(
      30,
      (i) => DrivingExercise(
        id: '$i',
        lessonId: 'l',
        orderIndex: i,
        type: ExerciseType.vocabulary,
        isExamQuestion: true,
        content: {'correct_index': 0},
      ),
    );
    // 26 correct answers (indices 0–25 answer correctly with value 0)
    final answers = {for (var i = 0; i < 30; i++) i: i < 26 ? 0 : 1};
    final state = ExamState(
      questions: exercises,
      currentIndex: 30,
      answers: answers,
      submitted: true,
    );
    expect(state.score, 26);
    expect(state.passed, true);
  });

  test('ExamState passed=false at exactly 25 correct', () {
    final exercises = List.generate(
      30,
      (i) => DrivingExercise(
        id: '$i',
        lessonId: 'l',
        orderIndex: i,
        type: ExerciseType.vocabulary,
        isExamQuestion: true,
        content: {'correct_index': 0},
      ),
    );
    final answers = {for (var i = 0; i < 30; i++) i: i < 25 ? 0 : 1};
    final state = ExamState(
      questions: exercises,
      currentIndex: 30,
      answers: answers,
      submitted: true,
    );
    expect(state.score, 25);
    expect(state.passed, false);
  });
}
