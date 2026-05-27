import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/features/learn/widgets/vocabulary_card.dart';
import 'package:cleared_driving/features/learn/widgets/fill_blank_widget.dart';

void main() {
  testWidgets('VocabularyCard shows term and flips on tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: VocabularyCard(term: 'עצור', definition: 'Stop'),
      ),
    ));
    expect(find.text('עצור'), findsOneWidget);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(find.text('Stop'), findsOneWidget);
  });

  testWidgets('FillBlankWidget shows word chips', (tester) async {
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
}
