import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/shared/widgets/onboarding_overlay.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows first step title on mount', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    expect(find.text('Learn by Category'), findsOneWidget);
  });

  testWidgets('advances to next step on Next tap', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Test Yourself'), findsOneWidget);
  });

  testWidgets('shows Get Started on last step', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('calls onDismiss when Get Started tapped', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () => dismissed = true),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    expect(dismissed, true);
  });

  testWidgets('Skip jumps to last step', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Skip button is absent on last step', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    expect(find.text('Skip'), findsNothing);
  });
}
