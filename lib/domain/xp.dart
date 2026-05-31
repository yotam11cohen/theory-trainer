abstract class XpCalculator {
  static const thresholds = [0, 500, 1500, 3000, 6000];

  static const _titles = [
    'Learner',
    'Student Driver',
    'Road Ready',
    'Theory Expert',
    'Road Master',
  ];

  static const _descriptions = [
    'רק מתחיל את הדרך',
    'לומד ומתקדם',
    'כמעט מוכן לכביש',
    'שולט בחומר',
    'אלוף הכביש',
  ];

  static String levelTitle(int level) =>
      _titles[(level - 1).clamp(0, _titles.length - 1)];

  static String levelDescription(int level) =>
      _descriptions[(level - 1).clamp(0, _descriptions.length - 1)];
  static const xpStandard = 10;
  static const xpPerfect = 15;

  static int levelFor(int totalXp) {
    for (var i = thresholds.length - 1; i >= 0; i--) {
      if (totalXp >= thresholds[i]) return i + 1;
    }
    return 1;
  }

  static int xpForScore(int score) => score == 100 ? xpPerfect : xpStandard;

  static int? nextThreshold(int level) {
    if (level >= thresholds.length) return null;
    return thresholds[level];
  }

  static double progressToNext(int totalXp, int level) {
    if (level < 1) return 0.0;
    if (level >= thresholds.length) return 1.0;
    final current = thresholds[level - 1];
    final next = thresholds[level];
    return ((totalXp - current) / (next - current)).clamp(0.0, 1.0);
  }
}
