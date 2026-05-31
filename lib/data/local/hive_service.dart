import 'package:hive_flutter/hive_flutter.dart';
import 'models/progress_event.dart';
import 'models/user_cache.dart';

abstract class HiveService {
  static const _progressQueueBox = 'progress_queue';
  static const _userCacheBox = 'user_cache';
  static const _completedLessonsBox = 'completed_lessons';
  static const _settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ProgressEventAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserCacheAdapter());
    await Hive.openBox<ProgressEvent>(_progressQueueBox);
    await Hive.openBox<UserCache>(_userCacheBox);
    await Hive.openBox<String>(_completedLessonsBox);
    await Hive.openBox<bool>(_settingsBox);
  }

  static Future<void> enqueueProgress(ProgressEvent event) async {
    await Hive.box<ProgressEvent>(_progressQueueBox).add(event);
  }

  static Future<List<ProgressEvent>> getPendingProgress() async {
    return Hive.box<ProgressEvent>(_progressQueueBox).values.toList();
  }

  static Future<void> clearProgressQueue() async {
    await Hive.box<ProgressEvent>(_progressQueueBox).clear();
  }

  static Future<void> cacheUser(UserCache cache) async {
    final box = Hive.box<UserCache>(_userCacheBox);
    await box.clear();
    await box.add(cache);
  }

  static UserCache? getCachedUser() {
    final box = Hive.box<UserCache>(_userCacheBox);
    return box.isEmpty ? null : box.getAt(0);
  }

  static Future<void> markLessonComplete(String lessonId) async {
    await Hive.box<String>(_completedLessonsBox).put(lessonId, lessonId);
  }

  static bool isLessonComplete(String lessonId) {
    return Hive.box<String>(_completedLessonsBox).containsKey(lessonId);
  }

  static Set<String> getCompletedLessonIds() {
    return Hive.box<String>(_completedLessonsBox).values.toSet();
  }

  static bool isOnboardingComplete() {
    return Hive.box<bool>(_settingsBox).get('onboardingComplete') ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    await Hive.box<bool>(_settingsBox).put('onboardingComplete', true);
  }

  static Future<void> resetOnboarding() async {
    await Hive.box<bool>(_settingsBox).delete('onboardingComplete');
  }
}
