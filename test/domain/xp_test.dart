import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/xp.dart';

void main() {
  group('XpCalculator', () {
    test('level 1 at 0 xp', () => expect(XpCalculator.levelFor(0), 1));
    test('level 2 at 500 xp', () => expect(XpCalculator.levelFor(500), 2));
    test('level 3 at 1500 xp', () => expect(XpCalculator.levelFor(1500), 3));
    test('level 4 at 3000 xp', () => expect(XpCalculator.levelFor(3000), 4));
    test('level 5 at 6000 xp', () => expect(XpCalculator.levelFor(6000), 5));
    test('level 5 stays at 9000 xp', () => expect(XpCalculator.levelFor(9000), 5));
    test('xpForPerfect returns 15', () => expect(XpCalculator.xpForScore(100), 15));
    test('xpForStandard returns 10', () => expect(XpCalculator.xpForScore(80), 10));
    test('nextLevelXp at level 1 is 500', () => expect(XpCalculator.nextThreshold(1), 500));
    test('nextLevelXp at level 5 is null', () => expect(XpCalculator.nextThreshold(5), null));
  });
}
