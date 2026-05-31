# Answer Explanations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** After every answered exercise, show a colored explanation card telling the user why the correct answer is right.

**Architecture:** Add an optional `explanation` getter to `DrivingExercise` (reads `content['explanation']`). `ExerciseShell` tracks whether the last answer was correct (`bool? _answeredCorrect`) and renders an explanation card between the exercise and the Next button when the explanation is non-null.

**Tech Stack:** Flutter, Dart. No new packages.

---

## File Map

- **Modify:** `lib/domain/models/driving_exercise.dart` — add `String? get explanation`
- **Modify:** `lib/features/learn/widgets/exercise_shell.dart` — track `_answeredCorrect`, render explanation card
- **Modify:** `test/domain/models/driving_exercise_test.dart` — add explanation getter tests
- **Modify:** `test/features/learn/exercise_shell_test.dart` — add explanation card tests

---

## Task 1: Add explanation getter to DrivingExercise

**Files:**
- Modify: `lib/domain/models/driving_exercise.dart`
- Modify: `test/domain/models/driving_exercise_test.dart`

Current `driving_exercise.dart` has getters like:
```dart
String get term => content['term'] as String;
String? get imageUrl => content['image_url'] as String?;
```

- [ ] **Step 1: Write the failing tests**

Add to `test/domain/models/driving_exercise_test.dart` inside the `'DrivingExercise typed getters'` group, after the last test:

```dart
test('explanation: returns null when absent', () {
  final ex = DrivingExercise(
    id: '5', lessonId: 'l', orderIndex: 0,
    type: ExerciseType.vocabulary, isExamQuestion: false,
    content: {'term': 'Stop', 'definition': 'עצור'},
  );
  expect(ex.explanation, isNull);
});

test('explanation: returns string when present', () {
  final ex = DrivingExercise(
    id: '6', lessonId: 'l', orderIndex: 0,
    type: ExerciseType.vocabulary, isExamQuestion: false,
    content: {'term': 'Stop', 'definition': 'עצור', 'explanation': 'A stop sign means you must come to a full stop.'},
  );
  expect(ex.explanation, 'A stop sign means you must come to a full stop.');
});
```

- [ ] **Step 2: Run tests to verify they fail**

```
cd "C:\Users\me\Downloads\Yotam\development\theory-trainer"
& "C:\src\flutter\bin\flutter.bat" test test/domain/models/driving_exercise_test.dart
```

Expected: FAIL — `explanation` getter not defined.

- [ ] **Step 3: Add the getter**

In `lib/domain/models/driving_exercise.dart`, after the `imageUrl` getter, add:

```dart
String? get explanation => content['explanation'] as String?;
```

- [ ] **Step 4: Run tests to verify they pass**

```
& "C:\src\flutter\bin\flutter.bat" test test/domain/models/driving_exercise_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```
git add lib/domain/models/driving_exercise.dart test/domain/models/driving_exercise_test.dart
git commit -m "feat: add optional explanation getter to DrivingExercise"
```

---

## Task 2: Show explanation card in ExerciseShell

**Files:**
- Modify: `lib/features/learn/widgets/exercise_shell.dart`
- Modify: `test/features/learn/exercise_shell_test.dart`

Current `_ExerciseShellState` has: `_index`, `_correct`, `_answered`.

Need to add `bool? _answeredCorrect` — set to `true` in `_onCorrect`, `false` in `_onWrong`, reset to `null` in `_next`.

- [ ] **Step 1: Write the failing tests**

Read `test/features/learn/exercise_shell_test.dart` to understand the existing test helper, then add these tests at the end of `main()`:

```dart
group('explanation card', () {
  testWidgets('shows explanation card after wrong answer when explanation is set', (tester) async {
    final exercises = [
      DrivingExercise(
        id: 'e1', lessonId: 'l1', orderIndex: 0,
        type: ExerciseType.listenChoose, isExamQuestion: false,
        content: {
          'text': 'What is a stop sign?',
          'options': ['Yield', 'Stop', 'Speed up'],
          'correct_index': 1,
          'explanation': 'A stop sign requires a full stop.',
        },
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseShell(exercises: exercises, onComplete: (_) {}),
        ),
      ),
    );
    // Tap wrong answer (index 0, correct is 1)
    await tester.tap(find.text('Yield'));
    await tester.pump();
    expect(find.text('A stop sign requires a full stop.'), findsOneWidget);
  });

  testWidgets('shows explanation card after correct answer when explanation is set', (tester) async {
    final exercises = [
      DrivingExercise(
        id: 'e2', lessonId: 'l1', orderIndex: 0,
        type: ExerciseType.listenChoose, isExamQuestion: false,
        content: {
          'text': 'What is a stop sign?',
          'options': ['Yield', 'Stop', 'Speed up'],
          'correct_index': 1,
          'explanation': 'A stop sign requires a full stop.',
        },
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseShell(exercises: exercises, onComplete: (_) {}),
        ),
      ),
    );
    // Tap correct answer (index 1)
    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('A stop sign requires a full stop.'), findsOneWidget);
  });

  testWidgets('hides explanation card when explanation is null', (tester) async {
    final exercises = [
      DrivingExercise(
        id: 'e3', lessonId: 'l1', orderIndex: 0,
        type: ExerciseType.listenChoose, isExamQuestion: false,
        content: {
          'text': 'What is a stop sign?',
          'options': ['Yield', 'Stop', 'Speed up'],
          'correct_index': 1,
        },
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseShell(exercises: exercises, onComplete: (_) {}),
        ),
      ),
    );
    await tester.tap(find.text('Yield'));
    await tester.pump();
    // No explanation text should appear
    expect(find.byType(Card), findsNothing);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```
& "C:\src\flutter\bin\flutter.bat" test test/features/learn/exercise_shell_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Update ExerciseShell**

Replace the full contents of `lib/features/learn/widgets/exercise_shell.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../domain/models/driving_exercise.dart';
import '../../../shared/sound_service.dart';
import 'vocabulary_card.dart';
import 'listen_choose_widget.dart';
import 'fill_blank_widget.dart';
import 'image_question_widget.dart';

class ExerciseShell extends StatefulWidget {
  final List<DrivingExercise> exercises;
  final void Function(int score) onComplete;

  const ExerciseShell({
    super.key,
    required this.exercises,
    required this.onComplete,
  });

  @override
  State<ExerciseShell> createState() => _ExerciseShellState();
}

class _ExerciseShellState extends State<ExerciseShell> {
  int _index = 0;
  int _correct = 0;
  bool _answered = false;
  bool? _answeredCorrect;

  void _onCorrect() => setState(() {
        _answered = true;
        _answeredCorrect = true;
        _correct++;
      });

  void _onWrong() {
    SoundService.playFail();
    setState(() {
      _answered = true;
      _answeredCorrect = false;
    });
  }

  void _next() {
    if (_index + 1 >= widget.exercises.length) {
      final score = (_correct / widget.exercises.length * 100).round();
      widget.onComplete(score);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _answeredCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercises[_index];
    final total = widget.exercises.length;

    return Column(
      children: [
        LinearProgressIndicator(value: (_index + 1) / total),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text('${_index + 1} / $total'),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildExercise(ex),
          ),
        ),
        if (_answered && ex.explanation != null && ex.explanation!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: _answeredCorrect == true
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _answeredCorrect == true
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: _answeredCorrect == true
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ex.explanation!,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_index + 1 >= total ? 'Finish' : 'Next'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExercise(DrivingExercise ex) {
    return switch (ex.type) {
      ExerciseType.vocabulary => VocabularyCard(
          key: ValueKey(ex.id),
          term: ex.term,
          definition: ex.definition,
          imageUrl: ex.imageUrl,
          onFlip: _onCorrect,
        ),
      ExerciseType.listenChoose => ListenChooseWidget(
          key: ValueKey(ex.id),
          text: ex.text,
          options: ex.options,
          correctIndex: ex.correctIndex,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
      ExerciseType.completePhrase => FillBlankWidget(
          key: ValueKey(ex.id),
          prompt: ex.prompt,
          answer: ex.answer,
          wordBank: ex.wordBank,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
      ExerciseType.imageQuestion => ImageQuestionWidget(
          key: ValueKey(ex.id),
          imageUrl: ex.imageUrl!,
          question: ex.question,
          options: ex.options,
          correctIndex: ex.correctIndex,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
    };
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
& "C:\src\flutter\bin\flutter.bat" test test/features/learn/exercise_shell_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Run all tests**

```
& "C:\src\flutter\bin\flutter.bat" test
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```
git add lib/features/learn/widgets/exercise_shell.dart test/features/learn/exercise_shell_test.dart
git commit -m "feat: show explanation card after every answered exercise"
```

---

## Task 3: Push

- [ ] **Step 1: Push**

```
git push
```
