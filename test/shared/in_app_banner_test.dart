import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/shared/in_app_banner.dart';

void main() {
  group('InAppBanner', () {
    testWidgets('shows emoji and message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  InAppBanner.show(context, emoji: '🎉', message: 'Level up!'),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump(); // trigger OverlayEntry insertion
      await tester.pump(const Duration(milliseconds: 400)); // animation frames

      expect(find.text('🎉'), findsOneWidget);
      expect(find.text('Level up!'), findsOneWidget);

      // Drain pending dismiss timer before test teardown
      await tester.pump(const Duration(seconds: 3, milliseconds: 400));
      await tester.pumpAndSettle();
    });

    testWidgets('dismisses after 3 seconds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  InAppBanner.show(context, emoji: '✅', message: 'Done'),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Done'), findsOneWidget);

      // Fire the 3s dismiss timer + drain the 350ms reverse animation
      await tester.pump(const Duration(seconds: 3, milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsNothing);
    });

    testWidgets('multiple calls stack separate banners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                InAppBanner.show(context, emoji: '⭐', message: 'First');
                InAppBanner.show(context, emoji: '🎉', message: 'Second');
              },
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      // Drain both pending 3s dismiss timers before test teardown
      await tester.pump(const Duration(seconds: 3, milliseconds: 400));
      await tester.pumpAndSettle();
    });
  });
}
