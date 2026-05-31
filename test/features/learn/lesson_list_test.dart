import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cleared_driving/data/local/models/progress_event.dart';
import 'package:cleared_driving/data/local/models/user_cache.dart';
import 'package:cleared_driving/domain/models/driving_lesson.dart';
import 'package:cleared_driving/features/learn/screens/lesson_list_screen.dart';
import 'package:cleared_driving/providers/lessons_provider.dart';

DrivingLesson _lesson(String id, int orderIndex) => DrivingLesson(
      id: id,
      vehicleId: 'v1',
      category: 'signs',
      orderIndex: orderIndex,
      title: 'Lesson $id',
      description: 'Desc $id',
    );

Widget _wrap(List<DrivingLesson> lessons) => ProviderScope(
      overrides: [
        lessonsProvider.overrideWith((_) => Future.value(lessons)),
      ],
      child: const MaterialApp(
        home: LessonListScreen(category: 'signs'),
      ),
    );

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_lesson_list_test_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ProgressEventAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserCacheAdapter());
    await Hive.openBox<ProgressEvent>('progress_queue');
    await Hive.openBox<String>('completed_lessons');
    await Hive.openBox<UserCache>('user_cache');
    await Hive.openBox<bool>('settings');
  });

  tearDown(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('LessonListScreen locking', () {
    testWidgets('first lesson is always unlocked (tappable)', (tester) async {
      final lessons = [_lesson('l1', 0), _lesson('l2', 1)];
      await tester.pumpWidget(_wrap(lessons));
      await tester.pumpAndSettle();
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Lesson l1'),
      );
      expect(tile.onTap, isNotNull);
    });

    testWidgets('second lesson is locked when first not completed', (tester) async {
      final lessons = [_lesson('l1', 0), _lesson('l2', 1)];
      await tester.pumpWidget(_wrap(lessons));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Lesson l2'),
      );
      expect(tile.onTap, isNull);
    });
  });
}
