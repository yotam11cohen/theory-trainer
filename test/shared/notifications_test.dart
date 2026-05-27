// test/shared/notifications_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/shared/notifications.dart';

void main() {
  test('daysSinceActive returns 0 for today', () {
    expect(NotificationScheduler.daysSinceActive(DateTime.now()), 0);
  });

  test('daysSinceActive returns >1 after 3 days of inactivity', () {
    final lastActive = DateTime.now().subtract(const Duration(days: 3));
    expect(NotificationScheduler.daysSinceActive(lastActive), greaterThan(1));
  });
}
