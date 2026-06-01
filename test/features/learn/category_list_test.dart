import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cleared_driving/data/local/models/progress_event.dart';
import 'package:cleared_driving/data/local/models/user_cache.dart';
import 'package:cleared_driving/domain/models/driving_lesson.dart';
import 'package:cleared_driving/features/learn/screens/category_list_screen.dart';
import 'package:cleared_driving/l10n/app_localizations.dart';
import 'package:cleared_driving/providers/lessons_provider.dart';

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_category_list_test_');
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

  testWidgets('CategoryListScreen shows 5 categories', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lessonsProvider.overrideWith((_) => Future.value(<DrivingLesson>[])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CategoryListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(5));
  });
}
