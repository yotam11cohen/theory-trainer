# Answer Explanations Design

## Goal

After every answered exercise, show an explanation card telling the user why the correct answer is right. Green card on correct, red card on wrong.

## Data Layer

`DrivingExercise.content` is a `Map<String, dynamic>` stored as JSONB in Supabase. Add an optional `explanation` field to this JSON per exercise.

Add a getter to `DrivingExercise`:
```dart
String? get explanation => content['explanation'] as String?;
```

No migration needed — the field is optional. Exercises without it simply show no explanation.

## UI

`ExerciseShell` already tracks `_answered` (bool) and `_correct` (int count). It knows the current exercise and whether the last answer was correct.

After answering, `ExerciseShell` shows an explanation card between the exercise widget and the "Next" button:

```
[exercise widget]
[explanation card — green if correct, red if wrong]   ← NEW
[Next button]
```

The card is shown only when:
- `_answered == true`
- `exercise.explanation != null && exercise.explanation!.isNotEmpty`

Card design:
- `Card` with `color: Colors.green.withValues(alpha: 0.12)` or `Colors.red.withValues(alpha: 0.12)`
- Leading icon: `Icons.check_circle` (green) or `Icons.info_outline` (red)
- Text: the explanation string, `textDirection: TextDirection.rtl`

## Files to change

- `lib/domain/models/driving_exercise.dart` — add `explanation` getter
- `lib/features/learn/widgets/exercise_shell.dart` — show explanation card when `_answered && explanation != null`

## Testing

- Unit: `DrivingExercise.explanation` returns null when absent, returns string when present
- Widget: `ExerciseShell` shows explanation card after wrong answer when explanation is set, hides it when explanation is null, shows green card on correct answer
