# Leaderboard Implementation Design

**Goal:** Add a global all-time leaderboard as a 5th tab, ranked by total XP, showing the top 50 users with the current user's position always visible.

**Architecture:** Two Supabase queries fetched in a single FutureProvider. Rank is the array index + 1 (no schema changes required). Current user's rank outside top 50 is resolved with a COUNT query using their known XP.

**Tech Stack:** Flutter, Riverpod FutureProvider, GoRouter StatefulShellBranch, Supabase Flutter.

---

## Data Layer

### New model: `lib/domain/models/leaderboard_entry.dart`

```dart
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final int totalXp;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalXp,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {required int rank}) =>
      LeaderboardEntry(
        rank: rank,
        userId: json['id'] as String,
        displayName: json['display_name'] as String? ?? '',
        totalXp: json['total_xp'] as int? ?? 0,
      );
}
```

### New model: `lib/domain/models/leaderboard_data.dart`

```dart
class LeaderboardData {
  final List<LeaderboardEntry> top50;
  final int currentUserRank; // rank of current user; -1 if unknown
  final bool currentUserInTop50;

  const LeaderboardData({
    required this.top50,
    required this.currentUserRank,
    required this.currentUserInTop50,
  });
}
```

### New methods on `SupabaseService`

**`fetchLeaderboard()`**
```
SELECT id, display_name, total_xp
FROM users
ORDER BY total_xp DESC
LIMIT 50
```
Returns `List<LeaderboardEntry>` with rank = index + 1.

**`fetchUserRank(String userId, int userXp)`**
```
SELECT COUNT(*) FROM users WHERE total_xp > userXp
```
Returns `count + 1` as the user's rank. Only called when the user is not in the top 50.

### New provider: `lib/providers/leaderboard_provider.dart`

`leaderboardProvider` is a `FutureProvider<LeaderboardData>` with no `keepAlive` (refreshes on each tab visit). It:
1. Reads `currentUserProvider` to get the current user's id.
2. Reads `userProfileProvider` to get current user's XP without an extra fetch.
3. Calls `fetchLeaderboard()`.
4. Checks if the current user appears in the top-50 list.
5. If not, calls `fetchUserRank(userId, userXp)` for the pinned row.
6. Returns `LeaderboardData`.

---

## UI

### Navigation changes

**`lib/shared/widgets/bottom_nav_shell.dart`** — add 5th `NavigationDestination`:
```dart
NavigationDestination(
  icon: const Icon(Icons.leaderboard_outlined),
  label: 'Leaderboard',
)
```

**`lib/router.dart`** — add 5th `StatefulShellBranch`:
```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: '/app/leaderboard',
    builder: (_, __) => const LeaderboardScreen(),
  ),
]),
```

### `lib/features/leaderboard/screens/leaderboard_screen.dart`

A `ConsumerWidget` that watches `leaderboardProvider`.

**Loading state:** `CircularProgressIndicator` centered.

**Error state:** Centered message + "Retry" `ElevatedButton` that calls `ref.invalidate(leaderboardProvider)`.

**Data state:** `ListView` of rows. Each row is a `ListTile`:
- `leading`: rank number (`Text('#$rank')`, bold, fixed-width)
- `title`: display name
- `trailing`: XP (`Text('$xp XP')`, muted style)
- `tileColor`: if this entry's `userId` matches the current user, use `Theme.of(context).colorScheme.primary.withOpacity(0.10)`

If `!currentUserInTop50`:
- A `Divider` after the last top-50 row
- A pinned row with the same tile style showing the user's own rank, name, and XP (data from `userProfileProvider`)

---

## Error Handling

- Both Supabase queries are wrapped in the FutureProvider's natural error propagation — errors bubble to the error state and the user sees a retry button.
- If `userProfileProvider` is not yet resolved when `leaderboardProvider` runs, it waits (`.valueOrNull` returns null → treat as "not in top 50", rank displayed as `—`).

---

## Testing

### Unit: `test/domain/models/leaderboard_entry_test.dart`
- `fromJson` parses `id`, `display_name`, `total_xp` correctly, with `rank` assigned
- `fromJson` defaults `display_name` to `''` and `total_xp` to `0` when absent

### Widget: `test/features/leaderboard/leaderboard_screen_test.dart`
- Shows `CircularProgressIndicator` while loading
- Shows retry button on error, calling `ref.invalidate` when tapped
- Renders top-50 rows with correct rank, name, XP text
- Highlights current user's row with colored background
- Shows pinned row below divider when current user is outside top 50
- Does NOT show pinned row when current user is already in top 50

---

## File Map

| Action | Path |
|--------|------|
| Create | `lib/domain/models/leaderboard_entry.dart` |
| Create | `lib/domain/models/leaderboard_data.dart` |
| Create | `lib/providers/leaderboard_provider.dart` |
| Create | `lib/features/leaderboard/screens/leaderboard_screen.dart` |
| Modify | `lib/data/remote/supabase_service.dart` |
| Modify | `lib/router.dart` |
| Modify | `lib/shared/widgets/bottom_nav_shell.dart` |
| Create | `test/domain/models/leaderboard_entry_test.dart` |
| Create | `test/features/leaderboard/leaderboard_screen_test.dart` |
