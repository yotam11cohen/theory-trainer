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

  @override
  String get learnTitle => 'לימוד';

  @override
  String get profileTitle => 'פרופיל';

  @override
  String get resultsTitle => 'תוצאות';

  @override
  String get lessonTitle => 'שיעור';

  @override
  String get categoriesTitle => 'קטגוריות';

  @override
  String lessonsDone(int count) {
    return '$count שיעורים הושלמו';
  }

  @override
  String pctComplete(int pct) {
    return '$pct% הושלם';
  }

  @override
  String get takeExam => 'למבחן ←';

  @override
  String continueLesson(String category, String lesson) {
    return 'המשך: $category — $lesson';
  }

  @override
  String get examByCategory => 'לפי קטגוריה';

  @override
  String get examReview => 'סקירה';

  @override
  String get goHome => 'לדף הבית';

  @override
  String get tryAgain => 'נסה שוב';

  @override
  String get leaderboardError => 'לא ניתן לטעון את לוח השיאים';

  @override
  String get retry => 'נסה שוב';

  @override
  String get showTutorial => 'הצג מדריך';

  @override
  String get deleteAccount => 'מחק חשבון';

  @override
  String get deleteAccountConfirmTitle => 'מחק חשבון';

  @override
  String get deleteAccountConfirmBody => 'פעולה זו תמחק לצמיתות את חשבונך ואת כל ההתקדמות שלך. לא ניתן לבטל.';

  @override
  String get delete => 'מחק';

  @override
  String get cancel => 'ביטול';

  @override
  String get editName => 'עריכת שם';

  @override
  String get displayName => 'שם תצוגה';

  @override
  String get save => 'שמור';

  @override
  String get failedUpdateName => 'לא ניתן לעדכן שם';

  @override
  String get failedDeleteAccount => 'לא ניתן למחוק חשבון';

  @override
  String get failedUpdateNotification => 'לא ניתן לעדכן העדפות התראות';

  @override
  String get languageLabel => 'שפה';

  @override
  String get noLessons => 'אין שיעורים בקטגוריה זו.';

  @override
  String get noExercises => 'אין תרגילים בשיעור זה.';

  @override
  String get offlineSaved => 'נשמר אופליין — יסונכרן בעת חיבור';

  @override
  String get firstLessonBanner => 'התחלה מצוינת! שיעור ראשון הושלם!';

  @override
  String levelUpBanner(String title, String description) {
    return 'עלית רמה! אתה עכשיו $title — $description';
  }

  @override
  String get categoryDoneBanner => 'קטגוריה הושלמה!';

  @override
  String get next => 'הבא';

  @override
  String get finish => 'סיים';

  @override
  String get couldNotLoadProfile => 'לא ניתן לטעון פרופיל';
}
