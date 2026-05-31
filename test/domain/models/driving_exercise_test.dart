import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/driving_exercise.dart';

void main() {
  group('DrivingExercise.fromJson', () {
    test('parses vocabulary type', () {
      final ex = DrivingExercise.fromJson({
        'id': '1',
        'lesson_id': 'l1',
        'order_index': 0,
        'type': 'vocabulary',
        'is_exam_question': false,
        'content': {'term': 'Stop', 'definition': 'עצור'},
      });
      expect(ex.type, ExerciseType.vocabulary);
      expect(ex.id, '1');
      expect(ex.lessonId, 'l1');
    });

    test('parses listen_choose type', () {
      final ex = DrivingExercise.fromJson({
        'id': '2',
        'lesson_id': 'l1',
        'order_index': 1,
        'type': 'listen_choose',
        'is_exam_question': true,
        'content': {'text': 'Q', 'options': ['A', 'B'], 'correct_index': 0},
      });
      expect(ex.type, ExerciseType.listenChoose);
      expect(ex.isExamQuestion, true);
    });

    test('parses complete_phrase type', () {
      final ex = DrivingExercise.fromJson({
        'id': '3',
        'lesson_id': 'l1',
        'order_index': 2,
        'type': 'complete_phrase',
        'is_exam_question': false,
        'content': {'prompt': 'Fill ___', 'answer': 'this', 'word_bank': ['this', 'that']},
      });
      expect(ex.type, ExerciseType.completePhrase);
    });

    test('parses image_question type', () {
      final ex = DrivingExercise.fromJson({
        'id': '4',
        'lesson_id': 'l1',
        'order_index': 3,
        'type': 'image_question',
        'is_exam_question': false,
        'content': {
          'image_url': 'https://example.com/img.png',
          'question': 'What is this?',
          'options': ['A', 'B'],
          'correct_index': 1,
        },
      });
      expect(ex.type, ExerciseType.imageQuestion);
    });

    test('defaults is_exam_question to false when absent', () {
      final ex = DrivingExercise.fromJson({
        'id': '5',
        'lesson_id': 'l1',
        'order_index': 0,
        'type': 'vocabulary',
        'content': {'term': 'T', 'definition': 'D'},
      });
      expect(ex.isExamQuestion, false);
    });

    test('throws ArgumentError for unknown type', () {
      expect(
        () => DrivingExercise.fromJson({
          'id': '6',
          'lesson_id': 'l1',
          'order_index': 0,
          'type': 'unknown_type',
          'content': {},
        }),
        throwsArgumentError,
      );
    });
  });

  group('DrivingExercise typed getters', () {
    late DrivingExercise vocab;
    late DrivingExercise listenEx;
    late DrivingExercise fillEx;
    late DrivingExercise imageEx;

    setUp(() {
      vocab = DrivingExercise(
        id: '1', lessonId: 'l', orderIndex: 0,
        type: ExerciseType.vocabulary, isExamQuestion: false,
        content: {'term': 'Stop', 'definition': 'עצור', 'image_url': null},
      );
      listenEx = DrivingExercise(
        id: '2', lessonId: 'l', orderIndex: 1,
        type: ExerciseType.listenChoose, isExamQuestion: false,
        content: {'text': 'Hello', 'options': ['A', 'B', 'C'], 'correct_index': 2},
      );
      fillEx = DrivingExercise(
        id: '3', lessonId: 'l', orderIndex: 2,
        type: ExerciseType.completePhrase, isExamQuestion: false,
        content: {'prompt': 'Fill ___', 'answer': 'right', 'word_bank': ['right', 'wrong']},
      );
      imageEx = DrivingExercise(
        id: '4', lessonId: 'l', orderIndex: 3,
        type: ExerciseType.imageQuestion, isExamQuestion: false,
        content: {
          'image_url': 'https://example.com/sign.png',
          'question': 'What sign?',
          'options': ['A', 'B'],
          'correct_index': 0,
        },
      );
    });

    test('vocabulary: term and definition', () {
      expect(vocab.term, 'Stop');
      expect(vocab.definition, 'עצור');
      expect(vocab.imageUrl, isNull);
    });

    test('listenChoose: text, options, correctIndex', () {
      expect(listenEx.text, 'Hello');
      expect(listenEx.options, ['A', 'B', 'C']);
      expect(listenEx.correctIndex, 2);
    });

    test('completePhrase: prompt, answer, wordBank', () {
      expect(fillEx.prompt, 'Fill ___');
      expect(fillEx.answer, 'right');
      expect(fillEx.wordBank, ['right', 'wrong']);
    });

    test('imageQuestion: imageUrl, question, options, correctIndex', () {
      expect(imageEx.imageUrl, 'https://example.com/sign.png');
      expect(imageEx.question, 'What sign?');
      expect(imageEx.options, ['A', 'B']);
      expect(imageEx.correctIndex, 0);
    });

    test('explanation: returns null when absent', () {
      final ex = DrivingExercise(
        id: '5', lessonId: 'l', orderIndex: 0,
        type: ExerciseType.vocabulary, isExamQuestion: false,
        content: {'term': 'Stop', 'definition': 'עצור'},
      );
      expect(ex.explanation, isNull);
    });

    test('explanation: returns string when present', () {
      final ex = DrivingExercise(
        id: '6', lessonId: 'l', orderIndex: 0,
        type: ExerciseType.vocabulary, isExamQuestion: false,
        content: {'term': 'Stop', 'definition': 'עצור', 'explanation': 'A stop sign means you must come to a full stop.'},
      );
      expect(ex.explanation, 'A stop sign means you must come to a full stop.');
    });
  });
}
