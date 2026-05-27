import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/features/dashboard/widgets/streak_card.dart';
import 'package:cleared_driving/features/dashboard/widgets/xp_bar.dart';

void main() {
  testWidgets('StreakCard shows streak count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StreakCard(streakCount: 7))),
    );
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('XpBar renders LinearProgressIndicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: XpBar(totalXp: 750, level: 2)),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
