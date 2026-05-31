# Sequential Lesson Locking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Within each category, only the first lesson is unlocked initially. Each subsequent lesson unlocks only after the previous one is completed.

**Architecture:** A pure function `_isUnlocked(lesson, categoryLessons, completedIds)` computes lock state client-side from already-available data. `LessonListScreen` applies this function to each lesson and renders locked lessons with a lock icon and no `onTap`.

**Tech Stack:** Flutter, Dart. No new packages, no DB changes.

---

## File Map

- **Modify:** `lib/features/learn/screens/lesson_list_screen.dart` — add `_isUnlocked` function, apply to each tile
- **Modify:** `test/features/learn/category_list_test.dart` — add lesson locking tests (or create `test/features/learn/lesson_list_test.dart`)

---

## Task 1: Add lock logic and locked tile to LessonListScreen

**Files:**
- Modify: `lib/features/learn/screens/lesson_list_screen.dart`
- Create: `test/features/learn/lesson_list_test.dart`

Current `lesson_list_screen.dart`:
```dart
itemBuilder: (context, i) {
  final lesson = filtered[i];
  final isDone = completed.contains(lesson.id);
  return ListTile(
    leading: Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : null),
    title: Text(lesson.title),
    subtitle: Text(lesson.description),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push('/app/learn/$category/${lesson.id}'),
  );
},
```

- [ ] **Step 1: Write the failing tests**

Create `test/features/learn/lesson_list_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  group('LessonListScreen locking', () {
    testWidgets('first lesson is always unlocked (tappable)', (tester) async {
      final lessons = [_lesson('l1', 0), _lesson('l2', 1)];
      await tester.pumpWidget(_wrap(lessons));
      await tester.pumpAndSettle();
      final tile = find.widgetWithText(ListTile, 'Lesson l1');
      final widget = tester.widget<ListTile>(tile);
      expect(widget.onTap, isNotNull);
    });

    testWidgets('second lesson is locked when first not completed', (tester) async {
      final lessons = [_lesson('l1', 0), _lesson('l2', 1)];
      await tester.pumpWidget(_wrap(lessons));
      await tester.pumpAndSettle();
      // Lock icon present for second lesson
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      // Second tile is not tappable
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Lesson l2'),
      );
      expect(tile.onTap, isNull);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```
cd "C:\Users\me\Downloads\Yotam\development\theory-trainer"
& "C:\src\flutter\bin\flutter.bat" test test/features/learn/lesson_list_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Update LessonListScreen**

Replace the full contents of `lib/features/learn/screens/lesson_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/driving_lesson.dart';
import '../../../providers/lessons_provider.dart';
import '../../../data/local/hive_service.dart';

bool _isUnlocked(
  DrivingLesson lesson,
  List<DrivingLesson> categoryLessons,
  Set<String> completedIds,
) {
  final sorted = [...categoryLessons]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final idx = sorted.indexWhere((l) => l.id == lesson.id);
  if (idx <= 0) return true;
  return completedIds.contains(sorted[idx - 1].id);
}

class LessonListScreen extends ConsumerWidget {
  final String category;
  const LessonListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final completed = HiveService.getCompletedLessonIds();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lessons) {
          final filtered = lessons
              .where((l) => l.category == category)
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          if (filtered.isEmpty) {
            return const Center(child: Text('No lessons in this category.'));
          }
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final lesson = filtered[i];
              final isDone = completed.contains(lesson.id);
              final unlocked = _isUnlocked(lesson, filtered, completed);
              return ListTile(
                leading: Icon(
                  isDone
                      ? Icons.check_circle
                      : unlocked
                          ? Icons.circle_outlined
                          : Icons.lock_outline,
                  color: isDone
                      ? Colors.green
                      : unlocked
                          ? null
                          : Colors.grey,
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  lesson.description,
                  style: TextStyle(
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
                trailing: unlocked
                    ? const Icon(Icons.chevron_right)
                    : null,
                onTap: unlocked
                    ? () => context.push('/app/learn/$category/${lesson.id}')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
& "C:\src\flutter\bin\flutter.bat" test test/features/learn/lesson_list_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Run all tests**

```
& "C:\src\flutter\bin\flutter.bat" test
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```
git add lib/features/learn/screens/lesson_list_screen.dart test/features/learn/lesson_list_test.dart
git commit -m "feat: lock lessons sequentially — each unlocks after previous is complete"
```

---

## Task 2: Push

- [ ] **Step 1: Push**

```
git push
```
