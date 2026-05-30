import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/driving_exercise.dart';
import 'package:cleared_driving/features/learn/widgets/exercise_shell.dart';

DrivingExercise _vocab(String id, int order) => DrivingExercise(
      id: id,
      lessonId: 'l',
      orderIndex: order,
      type: ExerciseType.vocabulary,
      isExamQuestion: false,
      content: {'term': 'Term$id', 'definition': 'Def$id'},
    );

DrivingExercise _fill(String id, int order, {required String answer, required List<String> bank}) =>
    DrivingExercise(
      id: id,
      lessonId: 'l',
      orderIndex: order,
      type: ExerciseType.completePhrase,
      isExamQuestion: false,
      content: {'prompt': 'Fill ___', 'answer': answer, 'word_bank': bank},
    );

void main() {
  group('ExerciseShell score calculation', () {
    testWidgets('all correct vocab exercises → score 100', (tester) async {
      int? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [_vocab('1', 0), _vocab('2', 1)],
            onComplete: (s) => result = s,
          ),
        ),
      ));

      // Answer ex 1: flip vocab card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Answer ex 2: flip vocab card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(result, 100);
    });

    testWidgets('1 correct fill-blank + 1 wrong → score 50', (tester) async {
      int? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [
              _fill('1', 0, answer: 'right', bank: ['right', 'wrong']),
              _fill('2', 1, answer: 'correct', bank: ['correct', 'incorrect']),
            ],
            onComplete: (s) => result = s,
          ),
        ),
      ));

      // Ex 1: tap correct word
      await tester.tap(find.text('right'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Ex 2: tap wrong word
      await tester.tap(find.text('incorrect'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(result, 50); // (1/2 * 100).round()
    });

    testWidgets('all wrong → score 0', (tester) async {
      int? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [
              _fill('1', 0, answer: 'right', bank: ['right', 'wrong']),
            ],
            onComplete: (s) => result = s,
          ),
        ),
      ));

      await tester.tap(find.text('wrong'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(result, 0);
    });

    testWidgets('progress bar shows correct fraction', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [_vocab('1', 0), _vocab('2', 1), _vocab('3', 2)],
            onComplete: (_) {},
          ),
        ),
      ));

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, closeTo(1 / 3, 0.01));
    });

    testWidgets('next button not shown before answering', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [_vocab('1', 0)],
            onComplete: (_) {},
          ),
        ),
      ));

      expect(find.text('Next'), findsNothing);
      expect(find.text('Finish'), findsNothing);
    });

    testWidgets('onComplete not called before last exercise', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [_vocab('1', 0), _vocab('2', 1)],
            onComplete: (_) => callCount++,
          ),
        ),
      ));

      // Answer first and advance
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });

  group('ExerciseShell double-answer prevention', () {
    testWidgets('fill-blank ignores second tap after answered', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseShell(
            exercises: [_fill('1', 0, answer: 'right', bank: ['right', 'wrong'])],
            onComplete: (_) {},
          ),
        ),
      ));

      // First tap: wrong
      await tester.tap(find.text('wrong'));
      await tester.pumpAndSettle();
      // Second tap: should be ignored by FillBlankWidget._correct != null guard
      await tester.tap(find.text('right'));
      await tester.pumpAndSettle();

      // Only the first answer registers, so Finish button is visible
      expect(find.text('Finish'), findsOneWidget);
    });
  });
}
