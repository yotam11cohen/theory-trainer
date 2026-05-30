// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cleared — Theory';

  @override
  String get tabHome => 'Home';

  @override
  String get tabLearn => 'Learn';

  @override
  String get tabExam => 'Exam';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabLeaderboard => 'Leaderboard';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get logoutButton => 'Sign Out';

  @override
  String streakLabel(int days) {
    return '$days day streak';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get continueStudying => 'Continue Studying';

  @override
  String categoryProgress(int pct) {
    return '$pct% complete';
  }

  @override
  String get examTitle => 'Theory Exam';

  @override
  String get examStart => 'Start Exam';

  @override
  String examQuestion(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get examPassed => 'Passed!';

  @override
  String get examFailed => 'Not Yet';

  @override
  String examScore(int score, int total) {
    return '$score/$total';
  }

  @override
  String get retryExam => 'Try Again';

  @override
  String get notificationsLabel => 'Study Reminders';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get loading => 'Loading...';

  @override
  String get homeTitle => 'Dashboard';
}
