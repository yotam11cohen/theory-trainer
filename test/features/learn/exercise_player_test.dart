import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/features/learn/widgets/vocabulary_card.dart';
import 'package:cleared_driving/features/learn/widgets/fill_blank_widget.dart';

void main() {
  group('VocabularyCard', () {
    testWidgets('shows term on front', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: VocabularyCard(term: 'עצור', definition: 'Stop')),
      ));
      expect(find.text('עצור'), findsOneWidget);
    });

    testWidgets('flips to definition on first tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: VocabularyCard(term: 'עצור', definition: 'Stop')),
      ));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('Stop'), findsOneWidget);
    });

    testWidgets('flips back to term on second tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: VocabularyCard(term: 'עצור', definition: 'Stop')),
      ));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('עצור'), findsOneWidget);
    });

    testWidgets('onFlip called only on first tap', (tester) async {
      var flipCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VocabularyCard(
            term: 'A', definition: 'B', onFlip: () => flipCount++,
          ),
        ),
      ));
      await tester.tap(find.byType(GestureDetector).first); // first flip
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first); // flip back
      await tester.pumpAndSettle();
      expect(flipCount, 1);
    });
  });

  group('FillBlankWidget', () {
    testWidgets('shows word chips for all bank words', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FillBlankWidget(
            prompt: 'יש לעצור ב___',
            answer: 'רמזור אדום',
            wordBank: const ['רמזור אדום', 'כביש', 'מהירות'],
            onCorrect: () {},
            onWrong: () {},
          ),
        ),
      ));
      expect(find.byType(ActionChip), findsNWidgets(3));
    });

    testWidgets('tapping correct word calls onCorrect', (tester) async {
      var correct = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FillBlankWidget(
            prompt: 'Fill ___',
            answer: 'right',
            wordBank: const ['right', 'wrong'],
            onCorrect: () => correct = true,
            onWrong: () {},
          ),
        ),
      ));
      await tester.tap(find.text('right'));
      await tester.pumpAndSettle();
      expect(correct, true);
    });

    testWidgets('tapping wrong word calls onWrong', (tester) async {
      var wrong = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FillBlankWidget(
            prompt: 'Fill ___',
            answer: 'right',
            wordBank: const ['right', 'wrong'],
            onCorrect: () {},
            onWrong: () => wrong = true,
          ),
        ),
      ));
      await tester.tap(find.text('wrong'));
      await tester.pumpAndSettle();
      expect(wrong, true);
    });

    testWidgets('second tap after answering is ignored', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FillBlankWidget(
            prompt: 'Fill ___',
            answer: 'right',
            wordBank: const ['right', 'wrong'],
            onCorrect: () => callCount++,
            onWrong: () => callCount++,
          ),
        ),
      ));
      await tester.tap(find.text('wrong'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('right'));
      await tester.pumpAndSettle();
      expect(callCount, 1);
    });
  });
}
