// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'קלירד — תאוריה';

  @override
  String get tabHome => 'בית';

  @override
  String get tabLearn => 'לימוד';

  @override
  String get tabExam => 'מבחן';

  @override
  String get tabProfile => 'פרופיל';

  @override
  String get tabLeaderboard => 'שיאים';

  @override
  String get loginTitle => 'ברוך הבא';

  @override
  String get loginEmail => 'אימייל';

  @override
  String get loginPassword => 'סיסמה';

  @override
  String get loginButton => 'התחבר';

  @override
  String get loginGoogle => 'המשך עם Google';

  @override
  String get registerTitle => 'צור חשבון';

  @override
  String get registerButton => 'הרשמה';

  @override
  String get logoutButton => 'התנתק';

  @override
  String streakLabel(int days) {
    return 'רצף $days ימים';
  }

  @override
  String xpLabel(int xp) {
    return '$xp נקודות';
  }

  @override
  String levelLabel(int level) {
    return 'רמה $level';
  }

  @override
  String get continueStudying => 'המשך ללמוד';

  @override
  String categoryProgress(int pct) {
    return '$pct% הושלם';
  }

  @override
  String get examTitle => 'מבחן תאוריה';

  @override
  String get examStart => 'התחל מבחן';

  @override
  String examQuestion(int n, int total) {
    return 'שאלה $n מתוך $total';
  }

  @override
  String get examPassed => 'עברת!';

  @override
  String get examFailed => 'עוד לא';

  @override
  String examScore(int score, int total) {
    return '$score/$total';
  }

  @override
  String get retryExam => 'נסה שוב';

  @override
  String get notificationsLabel => 'תזכורות לימוד';

  @override
  String get achievementsTitle => 'הישגים';

  @override
  String get errorGeneric => 'משהו השתבש. נסה שוב.';

  @override
  String get loading => 'טוען...';

  @override
  String get homeTitle => 'לוח בקרה';
}
