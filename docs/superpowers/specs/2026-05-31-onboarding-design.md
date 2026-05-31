# Onboarding Design

## Goal

Show first-time users a 5-step coach-mark overlay that highlights key app features in context, so they understand what the app does before they start studying.

## Architecture

The onboarding runs **on top of the existing app**, not as separate screens. An `OnboardingOverlay` widget sits inside `BottomNavShell` via a `Stack`. It renders a semi-transparent dark overlay with a spotlight cutout around the target UI element, an arrow, and a card with title + body text.

First-launch detection: `HiveService` stores a `bool` flag (`onboardingComplete`). On app start, if the flag is false, the overlay is shown. The "Show tutorial" button in the profile screen resets the flag, causing the overlay to re-appear on next visit to home.

The overlay is NOT a separate route — it appears on `/app/home` automatically.

## The 5 Steps

| # | Target element | Title | Body |
|---|---------------|-------|------|
| 1 | Learn tab (bottom nav) | Learn by Category | Study Signs, Laws, Safe Driving, Mechanics and First Aid at your own pace |
| 2 | Exam tab (bottom nav) | Test Yourself | Take a full 30-question theory exam when you're ready |
| 3 | XP bar on home screen | Track Your Progress | Earn XP, level up, and keep your streak alive |
| 4 | Leaderboard tab (bottom nav) | Compete with Others | See how you rank on the leaderboard against other learners |
| 5 | Home screen centre | You're ready! | Start your first lesson and work toward passing the theory exam |

## UI Behaviour

- **Progress bar** at top of overlay card shows current step (e.g. 2/5)
- **Next** button advances to next step
- **Skip** text button (top-right of card) jumps to last step
- **Get Started** button on step 5 dismisses overlay and writes completion flag
- **Swipe** left/right on the card also advances/retreats steps
- Spotlight cutout uses `GlobalKey` on the target widget to find its position and size via `RenderBox`
- Arrow points from card toward the highlighted element
- Tapping outside the card does nothing (prevents accidental dismissal)

## Components

### `OnboardingOverlay` (`lib/shared/widgets/onboarding_overlay.dart`)
- `StatefulWidget` — owns `PageController` and current step index
- Takes a `VoidCallback onDismiss`
- Reads step definitions from a const list of `OnboardingStep`
- Renders via `CustomPainter` for the spotlight hole + arrow

### `OnboardingStep` (`lib/shared/widgets/onboarding_overlay.dart`)
```dart
class OnboardingStep {
  final GlobalKey targetKey;
  final String title;
  final String body;
}
```

### `HiveService` additions
- `static Future<void> setOnboardingComplete()` — writes flag
- `static bool isOnboardingComplete()` — reads flag (sync, like existing getters)

### `BottomNavShell` changes
- Expose `GlobalKey`s on each `NavigationDestination` target area
- Wrap body in `Stack`, conditionally show `OnboardingOverlay` when flag is false

### Profile screen changes
- Add "Show tutorial" `ListTile` that calls `HiveService.resetOnboarding()` then navigates to `/app/home`

### `HiveService` additions
- `static Future<void> resetOnboarding()` — clears the flag

## Data Flow

1. App starts → `BottomNavShell` builds → checks `HiveService.isOnboardingComplete()`
2. If false → shows `OnboardingOverlay` on top of normal content
3. User taps through steps → overlay uses `GlobalKey.currentContext` to locate each target
4. On "Get Started" → `HiveService.setOnboardingComplete()` → `onDismiss()` called → overlay removed from tree
5. Profile "Show tutorial" → `HiveService.resetOnboarding()` → navigate to `/app/home` → overlay shows again

## Testing

- **Unit:** `HiveService` — `isOnboardingComplete()` false by default, true after `setOnboardingComplete()`, false again after `resetOnboarding()`
- **Widget:** `OnboardingOverlay` — shows step 1 title on mount, advances on "Next" tap, shows "Get Started" on step 5, calls `onDismiss` on "Get Started"
- **Widget:** `BottomNavShell` — overlay not shown when `isOnboardingComplete()` is true
