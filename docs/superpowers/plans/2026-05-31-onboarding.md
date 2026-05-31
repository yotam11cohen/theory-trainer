# Onboarding Coach-Mark Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show first-time users a 5-step coach-mark overlay that highlights key app features in context, with a "Show tutorial" button in profile to replay it.

**Architecture:** A full-screen semi-transparent `OnboardingOverlay` widget sits inside `BottomNavShell` via a `Stack`. Each step shows a card with title, body, progress bar, and an arrow pointing toward the relevant UI area (tabs or XP bar). First-launch detection uses a new boolean flag in `HiveService`. `BottomNavShell` is converted from `StatelessWidget` to `StatefulWidget` to manage overlay visibility.

**Tech Stack:** Flutter, Hive (for persistence), no new packages required.

---

## File Map

- **Create:** `lib/shared/widgets/onboarding_overlay.dart` — `OnboardingStep`, `OnboardingArrow` enum, `OnboardingOverlay` widget
- **Modify:** `lib/data/local/hive_service.dart` — add `_settingsBox`, `isOnboardingComplete()`, `setOnboardingComplete()`, `resetOnboarding()`
- **Modify:** `lib/shared/widgets/bottom_nav_shell.dart` — convert to `StatefulWidget`, add `Stack` + `OnboardingOverlay`
- **Modify:** `lib/features/profile/screens/profile_screen.dart` — add "Show tutorial" `ListTile`
- **Modify:** `test/data/local/hive_service_test.dart` — add onboarding flag tests
- **Create:** `test/shared/onboarding_overlay_test.dart` — widget tests for overlay

---

## Task 1: Add onboarding flag to HiveService

**Files:**
- Modify: `lib/data/local/hive_service.dart`
- Modify: `test/data/local/hive_service_test.dart`

- [ ] **Step 1: Write the failing tests**

Add to the bottom of `test/data/local/hive_service_test.dart`, inside `main()`:

```dart
group('onboarding flag', () {
  test('isOnboardingComplete returns false by default', () {
    expect(HiveService.isOnboardingComplete(), false);
  });

  test('setOnboardingComplete makes isOnboardingComplete return true', () async {
    await HiveService.setOnboardingComplete();
    expect(HiveService.isOnboardingComplete(), true);
  });

  test('resetOnboarding makes isOnboardingComplete return false again', () async {
    await HiveService.setOnboardingComplete();
    await HiveService.resetOnboarding();
    expect(HiveService.isOnboardingComplete(), false);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```
flutter test test/data/local/hive_service_test.dart
```

Expected: FAIL — `isOnboardingComplete` not defined.

- [ ] **Step 3: Add settings box and three methods to HiveService**

In `lib/data/local/hive_service.dart`, add `_settingsBox` constant and open it in `init()`, then add the three methods:

```dart
abstract class HiveService {
  static const _progressQueueBox = 'progress_queue';
  static const _userCacheBox = 'user_cache';
  static const _completedLessonsBox = 'completed_lessons';
  static const _settingsBox = 'settings';            // ADD THIS

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ProgressEventAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserCacheAdapter());
    await Hive.openBox<ProgressEvent>(_progressQueueBox);
    await Hive.openBox<UserCache>(_userCacheBox);
    await Hive.openBox<String>(_completedLessonsBox);
    await Hive.openBox<bool>(_settingsBox);           // ADD THIS
  }

  // ... existing methods unchanged ...

  // ADD THESE THREE METHODS at the bottom:
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
```

- [ ] **Step 4: Run tests to verify they pass**

```
flutter test test/data/local/hive_service_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```
git add lib/data/local/hive_service.dart test/data/local/hive_service_test.dart
git commit -m "feat: add onboarding completion flag to HiveService"
```

---

## Task 2: Create OnboardingOverlay widget

**Files:**
- Create: `lib/shared/widgets/onboarding_overlay.dart`
- Create: `test/shared/onboarding_overlay_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Create `test/shared/onboarding_overlay_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/shared/widgets/onboarding_overlay.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows first step title on mount', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    expect(find.text('Learn by Category'), findsOneWidget);
  });

  testWidgets('advances to next step on Next tap', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Test Yourself'), findsOneWidget);
  });

  testWidgets('shows Get Started on last step', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    // Advance to last step (5 steps total, tap Next 4 times)
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('calls onDismiss when Get Started tapped', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () => dismissed = true),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    expect(dismissed, true);
  });

  testWidgets('Skip jumps to last step', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingOverlay(onDismiss: () {}),
    ));
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(find.text('Get Started'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```
flutter test test/shared/onboarding_overlay_test.dart
```

Expected: FAIL — `OnboardingOverlay` not defined.

- [ ] **Step 3: Create the overlay widget**

Create `lib/shared/widgets/onboarding_overlay.dart`:

```dart
import 'package:flutter/material.dart';

enum OnboardingArrow { learnTab, examTab, xpBar, leaderboardTab, none }

class OnboardingStep {
  final String title;
  final String body;
  final OnboardingArrow arrow;

  const OnboardingStep({
    required this.title,
    required this.body,
    required this.arrow,
  });
}

const _steps = [
  OnboardingStep(
    title: 'Learn by Category',
    body: 'Study Signs, Laws, Safe Driving, Mechanics and First Aid at your own pace.',
    arrow: OnboardingArrow.learnTab,
  ),
  OnboardingStep(
    title: 'Test Yourself',
    body: 'Take a full 30-question theory exam when you\'re ready.',
    arrow: OnboardingArrow.examTab,
  ),
  OnboardingStep(
    title: 'Track Your Progress',
    body: 'Earn XP, level up, and keep your streak alive.',
    arrow: OnboardingArrow.xpBar,
  ),
  OnboardingStep(
    title: 'Compete with Others',
    body: 'See how you rank on the leaderboard against other learners.',
    arrow: OnboardingArrow.leaderboardTab,
  ),
  OnboardingStep(
    title: 'You\'re Ready!',
    body: 'Start your first lesson and work toward passing the theory exam.',
    arrow: OnboardingArrow.none,
  ),
];

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _index = 0;

  void _next() {
    if (_index + 1 >= _steps.length) {
      widget.onDismiss();
      return;
    }
    setState(() => _index++);
  }

  void _skip() => setState(() => _index = _steps.length - 1);

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;
    final size = MediaQuery.of(context).size;
    final tabWidth = size.width / 5;
    // Approximate bottom nav height
    const navHeight = 80.0;

    // Arrow target x positions for tabs (center of each tab)
    double? arrowX;
    bool arrowPointsDown = false;

    switch (step.arrow) {
      case OnboardingArrow.learnTab:
        arrowX = tabWidth * 1.5;
        arrowPointsDown = true;
      case OnboardingArrow.examTab:
        arrowX = tabWidth * 2.5;
        arrowPointsDown = true;
      case OnboardingArrow.leaderboardTab:
        arrowX = tabWidth * 4.5;
        arrowPointsDown = true;
      case OnboardingArrow.xpBar:
        arrowX = size.width / 2;
        arrowPointsDown = false;
      case OnboardingArrow.none:
        arrowX = null;
    }

    return ColoredBox(
      color: Colors.black.withOpacity(0.65),
      child: Stack(
        children: [
          // Arrow pointing to tab (bottom area)
          if (arrowX != null && arrowPointsDown)
            Positioned(
              bottom: navHeight + 4,
              left: arrowX - 16,
              child: const Icon(Icons.arrow_downward, color: Colors.white, size: 32),
            ),
          // Arrow pointing to XP bar (top area)
          if (arrowX != null && !arrowPointsDown)
            Positioned(
              top: 120,
              left: arrowX - 16,
              child: const Icon(Icons.arrow_upward, color: Colors.white, size: 32),
            ),
          // Card positioning
          if (step.arrow == OnboardingArrow.none)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCard(context, step, isLast),
              ),
            )
          else
            Positioned(
              left: 24,
              right: 24,
              bottom: arrowPointsDown ? navHeight + 48 : null,
              top: !arrowPointsDown ? 164 : null,
              child: _buildCard(context, step, isLast),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, OnboardingStep step, bool isLast) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_index + 1) / _steps.length,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${_index + 1} / ${_steps.length}',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Text(
              step.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(step.body, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLast)
                  TextButton(onPressed: _skip, child: const Text('Skip')),
                if (isLast) const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
flutter test test/shared/onboarding_overlay_test.dart
```

Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```
git add lib/shared/widgets/onboarding_overlay.dart test/shared/onboarding_overlay_test.dart
git commit -m "feat: add OnboardingOverlay widget with 5-step coach marks"
```

---

## Task 3: Wire overlay into BottomNavShell

**Files:**
- Modify: `lib/shared/widgets/bottom_nav_shell.dart`

- [ ] **Step 1: Convert BottomNavShell to StatefulWidget and add overlay**

Replace the entire contents of `lib/shared/widgets/bottom_nav_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/hive_service.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_overlay.dart';

class BottomNavShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const BottomNavShell({super.key, required this.navigationShell});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !HiveService.isOnboardingComplete();
  }

  void _dismissOnboarding() async {
    await HiveService.setOnboardingComplete();
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          if (_showOnboarding)
            Positioned.fill(
              child: OnboardingOverlay(onDismiss: _dismissOnboarding),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (i) => widget.navigationShell.goBranch(
          i,
          initialLocation: i == widget.navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined), label: l.tabHome),
          NavigationDestination(
              icon: const Icon(Icons.school_outlined), label: l.tabLearn),
          NavigationDestination(
              icon: const Icon(Icons.quiz_outlined), label: l.tabExam),
          NavigationDestination(
              icon: const Icon(Icons.person_outline), label: l.tabProfile),
          NavigationDestination(
              icon: const Icon(Icons.leaderboard_outlined),
              label: l.tabLeaderboard),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run all tests**

```
flutter test
```

Expected: All tests pass (no regressions).

- [ ] **Step 3: Commit**

```
git add lib/shared/widgets/bottom_nav_shell.dart
git commit -m "feat: show OnboardingOverlay on first launch in BottomNavShell"
```

---

## Task 4: Add "Show tutorial" button to Profile screen

**Files:**
- Modify: `lib/features/profile/screens/profile_screen.dart`

- [ ] **Step 1: Add the Show Tutorial ListTile**

In `lib/features/profile/screens/profile_screen.dart`, inside the `ListView` children, add after the notifications row (after the `const SizedBox(height: 24)` that follows the `Switch` row):

```dart
const SizedBox(height: 8),
ListTile(
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.help_outline),
  title: const Text('Show Tutorial'),
  onTap: () async {
    await HiveService.resetOnboarding();
    if (context.mounted) context.go('/app/home');
  },
),
const SizedBox(height: 16),
```

Also add the import at the top of the file:

```dart
import '../../../data/local/hive_service.dart';
```

- [ ] **Step 2: Run all tests**

```
flutter test
```

Expected: All tests pass.

- [ ] **Step 3: Commit**

```
git add lib/features/profile/screens/profile_screen.dart
git commit -m "feat: add Show Tutorial button to profile screen"
```

---

## Task 5: Final integration test and APK

- [ ] **Step 1: Run all tests**

```
flutter test
```

Expected: All tests pass.

- [ ] **Step 2: Build and smoke-test on emulator**

```
flutter run -d emulator-5554 \
  --dart-define=SUPABASE_URL=https://hdimopgovbvxgveimxro.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<key>
```

Verify:
- Fresh install (or after clearing app data): overlay appears on home screen
- Tapping Next advances through all 5 steps
- Progress bar fills correctly
- Get Started dismisses the overlay
- Skip jumps to step 5
- Profile → Show Tutorial → back to home → overlay reappears

- [ ] **Step 3: Commit if any fixes were needed, then push**

```
git push
```
