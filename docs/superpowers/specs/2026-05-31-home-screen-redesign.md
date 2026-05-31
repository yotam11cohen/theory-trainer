# Home Screen Redesign

## Goal

Replace the sparse home screen with a dashboard showing overall progress, category breakdown, and a context-aware Continue Studying button.

## Layout (top to bottom)

1. **StreakCard** — unchanged
2. **XpBar** — unchanged
3. **Summary stats row** — 3 chips: "X lessons done", "X% complete", "Level X — {title}"
4. **Category breakdown** — 5 rows, each: icon + Hebrew name + LinearProgressIndicator + "X/Y"
5. **Continue Studying button** — "Continue: {categoryName} — {lessonTitle}" or "Take the Exam →" if all lessons done

## Data sources

- `lessonsProvider` — all lessons (already available on home screen)
- `HiveService.getCompletedLessonIds()` — completed lesson IDs (sync, already used)
- `userProfileProvider` — level and XP (already available)
- `AppConstants.categories` — category list with icons and Hebrew names

## Files to change

- `lib/features/dashboard/screens/home_screen.dart` — full rewrite
- `lib/features/dashboard/widgets/streak_card.dart` — unchanged
- `lib/features/dashboard/widgets/xp_bar.dart` — unchanged
