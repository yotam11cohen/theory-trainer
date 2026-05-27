import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cleared_driving/data/local/hive_service.dart';
import 'package:cleared_driving/data/local/models/progress_event.dart';

void main() {
  setUp(() async {
    // Use a real temp directory because Hive.initFlutter() requires the
    // path_provider platform plugin which is unavailable in unit tests.
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    // Guard against duplicate registration when setUp runs for subsequent tests.
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ProgressEventAdapter());
    }
    await Hive.openBox<ProgressEvent>('progress_queue');
    await Hive.openBox<String>('completed_lessons');
  });

  tearDown(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  test('enqueue and flush progress events', () async {
    await HiveService.enqueueProgress(
      ProgressEvent(lessonId: 'l1', score: 100, earnedAt: DateTime(2026, 1, 1)),
    );
    final queue = await HiveService.getPendingProgress();
    expect(queue.length, 1);
    expect(queue.first.lessonId, 'l1');

    await HiveService.clearProgressQueue();
    expect((await HiveService.getPendingProgress()).length, 0);
  });

  test('markLessonComplete and isLessonComplete', () async {
    expect(HiveService.isLessonComplete('lesson-1'), false);
    await HiveService.markLessonComplete('lesson-1');
    expect(HiveService.isLessonComplete('lesson-1'), true);
  });
}
