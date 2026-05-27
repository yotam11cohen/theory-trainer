abstract class XpCalculator {
  static const _thresholds = [0, 500, 1500, 3000, 6000];

  static int levelFor(int totalXp) {
    for (var i = _thresholds.length - 1; i >= 0; i--) {
      if (totalXp >= _thresholds[i]) return i + 1;
    }
    return 1;
  }

  static int xpForScore(int score) => score == 100 ? 15 : 10;

  static int? nextThreshold(int level) {
    if (level >= _thresholds.length) return null;
    return _thresholds[level];
  }

  static double progressToNext(int totalXp, int level) {
    if (level < 1) return 0.0;
    if (level >= _thresholds.length) return 1.0;
    final current = _thresholds[level - 1];
    final next = _thresholds[level];
    return ((totalXp - current) / (next - current)).clamp(0.0, 1.0);
  }
}
