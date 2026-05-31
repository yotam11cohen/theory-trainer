# Sequential Lesson Locking Design

## Goal

Within each category, only the first lesson is unlocked initially. Each subsequent lesson unlocks only after the previous one is completed.

## Logic

A lesson at `order_index N` is **unlocked** if:
- It is the first lesson in the category (`order_index == minimum order_index for that category`), OR
- The lesson with `order_index N-1` in the same category is in the user's completed set

This is computed client-side. No DB changes needed — `order_index` and completed lesson IDs are already available.

```dart
bool isLessonUnlocked(DrivingLesson lesson, List<DrivingLesson> categoryLessons, Set<String> completedIds) {
  final sorted = [...categoryLessons]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final idx = sorted.indexWhere((l) => l.id == lesson.id);
  if (idx == 0) return true;
  return completedIds.contains(sorted[idx - 1].id);
}
```

## UI — LessonListScreen

Currently each lesson renders as a tappable `ListTile`. Changes:

- **Locked lesson:** `ListTile` with `enabled: false`, trailing `Icon(Icons.lock_outline, color: Colors.grey)`, `onTap: null`
- **Unlocked lesson:** unchanged (tappable, no lock icon)
- **Completed lesson:** existing checkmark behaviour preserved

The lock check happens inside `LessonListScreen` using the already-fetched `lessonsProvider` and `HiveService.getCompletedLessonIds()`.

## Files to change

- `lib/features/learn/screens/lesson_list_screen.dart` — add lock logic and locked tile rendering

## Testing

- Unit: `isLessonUnlocked` function — first lesson always unlocked, second locked when first not complete, second unlocked when first complete
- Widget: `LessonListScreen` — first lesson tappable, second lesson shows lock icon when first not completed
