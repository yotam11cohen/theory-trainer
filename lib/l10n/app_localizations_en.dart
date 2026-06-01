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
  String get tabLeaderboard => 'Leader';

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

  @override
  String get learnTitle => 'Learn';

  @override
  String get profileTitle => 'Profile';

  @override
  String get resultsTitle => 'Results';

  @override
  String get lessonTitle => 'Lesson';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String lessonsDone(int count) {
    return '$count lessons done';
  }

  @override
  String pctComplete(int pct) {
    return '$pct% complete';
  }

  @override
  String get takeExam => 'Take the Exam →';

  @override
  String continueLesson(String category, String lesson) {
    return 'Continue: $category — $lesson';
  }

  @override
  String get examByCategory => 'By Category';

  @override
  String get examReview => 'Review';

  @override
  String get goHome => 'Go Home';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get leaderboardError => 'Could not load leaderboard';

  @override
  String get retry => 'Retry';

  @override
  String get showTutorial => 'Show Tutorial';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmBody => 'This will permanently delete your account and all your progress. This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get editName => 'Edit Name';

  @override
  String get displayName => 'Display name';

  @override
  String get save => 'Save';

  @override
  String get failedUpdateName => 'Failed to update name';

  @override
  String get failedDeleteAccount => 'Failed to delete account';

  @override
  String get failedUpdateNotification => 'Failed to update notification preference';

  @override
  String get languageLabel => 'Language';

  @override
  String get noLessons => 'No lessons in this category.';

  @override
  String get noExercises => 'No exercises in this lesson.';

  @override
  String get offlineSaved => 'Saved offline — will sync when connected';

  @override
  String get firstLessonBanner => 'Great start! First lesson complete!';

  @override
  String levelUpBanner(String title, String description) {
    return 'Level up! You are now $title — $description';
  }

  @override
  String get categoryDoneBanner => 'Category complete!';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get couldNotLoadProfile => 'Could not load profile';
}
