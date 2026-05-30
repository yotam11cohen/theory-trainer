import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/shared/notifications.dart';

void main() {
  group('NotificationScheduler.daysSinceActive', () {
    test('returns 0 for today', () {
      expect(NotificationScheduler.daysSinceActive(DateTime.now()), 0);
    });

    test('returns 0 even when earlier today', () {
      final earlier = DateTime.now().subtract(const Duration(hours: 5));
      expect(NotificationScheduler.daysSinceActive(earlier), 0);
    });

    test('returns 1 for exactly 1 day ago', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(NotificationScheduler.daysSinceActive(yesterday), 1);
    });

    test('returns 7 for exactly 7 days ago', () {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      expect(NotificationScheduler.daysSinceActive(weekAgo), 7);
    });

    test('returns 3 for 3 days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(NotificationScheduler.daysSinceActive(threeDaysAgo), 3);
    });

    test('threshold: days >= 1 triggers 1-day reminder', () {
      final days = NotificationScheduler.daysSinceActive(
          DateTime.now().subtract(const Duration(days: 1)));
      expect(days >= 1, isTrue);
      expect(days >= 7, isFalse);
    });

    test('threshold: days >= 7 triggers weekly reminder', () {
      final days = NotificationScheduler.daysSinceActive(
          DateTime.now().subtract(const Duration(days: 7)));
      expect(days >= 7, isTrue);
    });
  });
}
