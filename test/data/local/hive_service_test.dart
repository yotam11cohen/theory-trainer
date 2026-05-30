import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cleared_driving/data/local/hive_service.dart';
import 'package:cleared_driving/data/local/models/progress_event.dart';
import 'package:cleared_driving/data/local/models/user_cache.dart';

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ProgressEventAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserCacheAdapter());
    await Hive.openBox<ProgressEvent>('progress_queue');
    await Hive.openBox<String>('completed_lessons');
    await Hive.openBox<UserCache>('user_cache');
  });

  tearDown(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('progress queue', () {
    test('enqueue and clear single event', () async {
      await HiveService.enqueueProgress(
        ProgressEvent(lessonId: 'l1', score: 100, earnedAt: DateTime(2026, 1, 1)),
      );
      final queue = await HiveService.getPendingProgress();
      expect(queue.length, 1);
      expect(queue.first.lessonId, 'l1');

      await HiveService.clearProgressQueue();
      expect((await HiveService.getPendingProgress()).length, 0);
    });

    test('empty queue returns empty list', () async {
      expect((await HiveService.getPendingProgress()).length, 0);
    });

    test('multiple events preserved in order', () async {
      await HiveService.enqueueProgress(ProgressEvent(lessonId: 'a', score: 80, earnedAt: DateTime(2026, 1, 1)));
      await HiveService.enqueueProgress(ProgressEvent(lessonId: 'b', score: 100, earnedAt: DateTime(2026, 1, 2)));
      final queue = await HiveService.getPendingProgress();
      expect(queue.length, 2);
      expect(queue.map((e) => e.lessonId).toList(), ['a', 'b']);
    });
  });

  group('completed lessons', () {
    test('isLessonComplete false before marking', () {
      expect(HiveService.isLessonComplete('lesson-1'), false);
    });

    test('markLessonComplete and isLessonComplete', () async {
      await HiveService.markLessonComplete('lesson-1');
      expect(HiveService.isLessonComplete('lesson-1'), true);
    });

    test('getCompletedLessonIds returns all marked lessons', () async {
      await HiveService.markLessonComplete('l1');
      await HiveService.markLessonComplete('l2');
      final ids = HiveService.getCompletedLessonIds();
      expect(ids, containsAll(['l1', 'l2']));
      expect(ids.length, 2);
    });

    test('marking same lesson twice does not duplicate', () async {
      await HiveService.markLessonComplete('l1');
      await HiveService.markLessonComplete('l1');
      expect(HiveService.getCompletedLessonIds().length, 1);
    });
  });

  group('user cache', () {
    test('getCachedUser returns null when empty', () {
      expect(HiveService.getCachedUser(), isNull);
    });

    test('cacheUser and getCachedUser round-trip', () async {
      await HiveService.cacheUser(UserCache(
        totalXp: 750, level: 2, streakCount: 5, lastActive: '2026-05-30',
      ));
      final cached = HiveService.getCachedUser();
      expect(cached, isNotNull);
      expect(cached!.totalXp, 750);
      expect(cached.level, 2);
      expect(cached.streakCount, 5);
      expect(cached.lastActive, '2026-05-30');
    });

    test('cacheUser overwrites previous cache', () async {
      await HiveService.cacheUser(UserCache(totalXp: 100, level: 1, streakCount: 1));
      await HiveService.cacheUser(UserCache(totalXp: 500, level: 2, streakCount: 3));
      final cached = HiveService.getCachedUser();
      expect(cached!.totalXp, 500);
      expect(cached.level, 2);
    });
  });
}
