# Leaderboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a global all-time leaderboard as a 5th bottom-nav tab showing the top 50 users ranked by XP, with the current user's position always visible.

**Architecture:** Two Supabase queries (`SELECT top 50 by XP` and `COUNT users with more XP`) combined in a single FutureProvider. Models carry all display data so the screen watches only one provider. Navigation wired as a new `StatefulShellBranch` in GoRouter.

**Tech Stack:** Flutter, Riverpod 2.x FutureProvider, GoRouter, Supabase Flutter, flutter_test.

---

## File Map

| Action | Path |
|--------|------|
| Create | `lib/domain/models/leaderboard_entry.dart` |
| Create | `lib/domain/models/leaderboard_data.dart` |
| Modify | `lib/data/remote/supabase_service.dart` |
| Create | `lib/providers/leaderboard_provider.dart` |
| Create | `lib/features/leaderboard/screens/leaderboard_screen.dart` |
| Modify | `lib/l10n/app_localizations.dart` |
| Modify | `lib/l10n/app_localizations_en.dart` |
| Modify | `lib/l10n/app_localizations_he.dart` |
| Modify | `lib/router.dart` |
| Modify | `lib/shared/widgets/bottom_nav_shell.dart` |
| Create | `test/domain/models/leaderboard_entry_test.dart` |
| Create | `test/features/leaderboard/leaderboard_screen_test.dart` |

---

### Task 1: LeaderboardEntry model

**Files:**
- Create: `lib/domain/models/leaderboard_entry.dart`
- Create: `test/domain/models/leaderboard_entry_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/domain/models/leaderboard_entry_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry.fromJson', () {
    test('parses all fields correctly', () {
      final entry = LeaderboardEntry.fromJson(
        {'id': 'u1', 'display_name': 'Alice', 'total_xp': 1250},
        rank: 3,
      );
      expect(entry.rank, 3);
      expect(entry.userId, 'u1');
      expect(entry.displayName, 'Alice');
      expect(entry.totalXp, 1250);
    });

    test('defaults display_name to empty string when absent', () {
      final entry = LeaderboardEntry.fromJson(
        {'id': 'u1', 'total_xp': 500},
        rank: 1,
      );
      expect(entry.displayName, '');
    });

    test('defaults total_xp to 0 when absent', () {
      final entry = LeaderboardEntry.fromJson(
        {'id': 'u1', 'display_name': 'Bob'},
        rank: 2,
      );
      expect(entry.totalXp, 0);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```
flutter test test/domain/models/leaderboard_entry_test.dart
```

Expected: `Error: 'package:cleared_driving/domain/models/leaderboard_entry.dart' not found`

- [ ] **Step 3: Implement the model**

Create `lib/domain/models/leaderboard_entry.dart`:

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

- [ ] **Step 4: Run tests — expect PASS**

```
flutter test test/domain/models/leaderboard_entry_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```
git add lib/domain/models/leaderboard_entry.dart test/domain/models/leaderboard_entry_test.dart
git commit -m "feat: add LeaderboardEntry model"
```

---

### Task 2: LeaderboardData model + SupabaseService methods

**Files:**
- Create: `lib/domain/models/leaderboard_data.dart`
- Modify: `lib/data/remote/supabase_service.dart`

- [ ] **Step 1: Create LeaderboardData model**

Create `lib/domain/models/leaderboard_data.dart`:

```dart
import 'leaderboard_entry.dart';

class LeaderboardData {
  final List<LeaderboardEntry> top50;
  final String currentUserId;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardData({
    required this.top50,
    required this.currentUserId,
    required this.currentUserEntry,
  });
}
```

- [ ] **Step 2: Add fetchLeaderboard() to SupabaseService**

Open `lib/data/remote/supabase_service.dart`. Add these two methods before `signOut()`:

```dart
  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final data = await _client
        .from('users')
        .select('id, display_name, total_xp')
        .order('total_xp', ascending: false)
        .limit(50);
    return (data as List)
        .asMap()
        .entries
        .map((e) => LeaderboardEntry.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              rank: e.key + 1,
            ))
        .toList();
  }

  Future<int> fetchUserRank(String userId, int userXp) async {
    final data = await _client
        .from('users')
        .select('id')
        .gt('total_xp', userXp);
    return (data as List).length + 1;
  }
```

Also add the import at the top of `lib/data/remote/supabase_service.dart` (alongside existing imports):

```dart
import '../../domain/models/leaderboard_entry.dart';
```

- [ ] **Step 3: Run the full test suite — expect all green**

```
flutter test
```

Expected: all tests pass (new model files don't break anything).

- [ ] **Step 4: Commit**

```
git add lib/domain/models/leaderboard_data.dart lib/data/remote/supabase_service.dart
git commit -m "feat: add LeaderboardData model and SupabaseService leaderboard methods"
```

---

### Task 3: leaderboardProvider

**Files:**
- Create: `lib/providers/leaderboard_provider.dart`

- [ ] **Step 1: Create the provider**

Create `lib/providers/leaderboard_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/leaderboard_data.dart';
import '../domain/models/leaderboard_entry.dart';
import 'auth_provider.dart';
import 'supabase_provider.dart';
import 'user_provider.dart';

final leaderboardProvider = FutureProvider<LeaderboardData>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const LeaderboardData(top50: [], currentUserId: '', currentUserEntry: null);
  }

  final profile = ref.watch(userProfileProvider).valueOrNull;
  final service = ref.watch(supabaseServiceProvider);

  final top50 = await service.fetchLeaderboard();
  final inTop50 = top50.any((e) => e.userId == user.id);

  LeaderboardEntry? currentUserEntry;
  if (!inTop50 && profile != null) {
    final rank = await service.fetchUserRank(user.id, profile.totalXp);
    currentUserEntry = LeaderboardEntry(
      rank: rank,
      userId: user.id,
      displayName: profile.displayName,
      totalXp: profile.totalXp,
    );
  }

  return LeaderboardData(
    top50: top50,
    currentUserId: user.id,
    currentUserEntry: currentUserEntry,
  );
});
```

- [ ] **Step 2: Run the full test suite — expect all green**

```
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Commit**

```
git add lib/providers/leaderboard_provider.dart
git commit -m "feat: add leaderboardProvider"
```

---

### Task 4: LeaderboardScreen

**Files:**
- Create: `lib/features/leaderboard/screens/leaderboard_screen.dart`
- Create: `test/features/leaderboard/leaderboard_screen_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Create `test/features/leaderboard/leaderboard_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/domain/models/leaderboard_data.dart';
import 'package:cleared_driving/domain/models/leaderboard_entry.dart';
import 'package:cleared_driving/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:cleared_driving/providers/leaderboard_provider.dart';

LeaderboardEntry _e(int rank, String userId, String name, int xp) =>
    LeaderboardEntry(rank: rank, userId: userId, displayName: name, totalXp: xp);

Widget _wrap(AsyncValue<LeaderboardData> value) => ProviderScope(
      overrides: [leaderboardProvider.overrideWithValue(value)],
      child: const MaterialApp(home: LeaderboardScreen()),
    );

void main() {
  group('LeaderboardScreen', () {
    testWidgets('shows loading spinner while loading', (tester) async {
      await tester.pumpWidget(_wrap(const AsyncValue.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(
        _wrap(AsyncValue.error(Exception('fail'), StackTrace.empty)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders rank, name and XP for each entry', (tester) async {
      final data = LeaderboardData(
        top50: [_e(1, 'u1', 'Alice', 1500), _e(2, 'u2', 'Bob', 900)],
        currentUserId: 'other',
        currentUserEntry: null,
      );
      await tester.pumpWidget(_wrap(AsyncValue.data(data)));
      await tester.pumpAndSettle();
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('1500 XP'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('900 XP'), findsOneWidget);
    });

    testWidgets('no divider or pinned row when current user is in top 50', (tester) async {
      final data = LeaderboardData(
        top50: [_e(1, 'me', 'Me', 2000)],
        currentUserId: 'me',
        currentUserEntry: null,
      );
      await tester.pumpWidget(_wrap(AsyncValue.data(data)));
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('shows pinned row below divider when user is outside top 50', (tester) async {
      final data = LeaderboardData(
        top50: [_e(1, 'u1', 'Alice', 1500)],
        currentUserId: 'me',
        currentUserEntry: _e(42, 'me', 'Me', 200),
      );
      await tester.pumpWidget(_wrap(AsyncValue.data(data)));
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('#42'), findsOneWidget);
      expect(find.text('200 XP'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```
flutter test test/features/leaderboard/leaderboard_screen_test.dart
```

Expected: `Error: 'package:cleared_driving/features/leaderboard/screens/leaderboard_screen.dart' not found`

- [ ] **Step 3: Implement the screen**

Create `lib/features/leaderboard/screens/leaderboard_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/leaderboard_entry.dart';
import '../../../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load leaderboard'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(leaderboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final pinnedEntry = data.currentUserEntry;
          final highlight =
              Theme.of(context).colorScheme.primary.withOpacity(0.10);

          return ListView.builder(
            itemCount: data.top50.length + (pinnedEntry != null ? 2 : 0),
            itemBuilder: (context, index) {
              if (index < data.top50.length) {
                final entry = data.top50[index];
                return _LeaderboardTile(
                  entry: entry,
                  highlight: entry.userId == data.currentUserId ? highlight : null,
                );
              }
              if (index == data.top50.length) return const Divider();
              return _LeaderboardTile(entry: pinnedEntry!, highlight: highlight);
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final Color? highlight;

  const _LeaderboardTile({required this.entry, this.highlight});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: highlight,
      leading: SizedBox(
        width: 36,
        child: Text(
          '#${entry.rank}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(entry.displayName),
      trailing: Text(
        '${entry.totalXp} XP',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests — expect PASS**

```
flutter test test/features/leaderboard/leaderboard_screen_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Run full suite**

```
flutter test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```
git add lib/features/leaderboard/screens/leaderboard_screen.dart test/features/leaderboard/leaderboard_screen_test.dart
git commit -m "feat: add LeaderboardScreen"
```

---

### Task 5: Navigation wiring

**Files:**
- Modify: `lib/l10n/app_localizations.dart`
- Modify: `lib/l10n/app_localizations_en.dart`
- Modify: `lib/l10n/app_localizations_he.dart`
- Modify: `lib/router.dart`
- Modify: `lib/shared/widgets/bottom_nav_shell.dart`

- [ ] **Step 1: Add tabLeaderboard to the abstract localizations class**

In `lib/l10n/app_localizations.dart`, add this getter after the `tabProfile` getter (around line 126):

```dart
  /// No description provided for @tabLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get tabLeaderboard;
```

- [ ] **Step 2: Add English translation**

In `lib/l10n/app_localizations_en.dart`, add after `get tabProfile`:

```dart
  @override
  String get tabLeaderboard => 'Leaderboard';
```

- [ ] **Step 3: Add Hebrew translation**

In `lib/l10n/app_localizations_he.dart`, add after `get tabProfile`:

```dart
  @override
  String get tabLeaderboard => 'טבלת שיאים';
```

- [ ] **Step 4: Add 5th branch in router**

In `lib/router.dart`, add the import at the top:

```dart
import 'features/leaderboard/screens/leaderboard_screen.dart';
```

Then in the `branches` list, add a new `StatefulShellBranch` after the profile branch:

```dart
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/leaderboard',
              builder: (_, __) => const LeaderboardScreen(),
            ),
          ]),
```

- [ ] **Step 5: Add 5th destination in BottomNavShell**

In `lib/shared/widgets/bottom_nav_shell.dart`, add after the profile `NavigationDestination`:

```dart
          NavigationDestination(
            icon: const Icon(Icons.leaderboard_outlined),
            label: l.tabLeaderboard,
          ),
```

- [ ] **Step 6: Run the full test suite — expect all green**

```
flutter test
```

Expected: all tests pass.

- [ ] **Step 7: Commit**

```
git add lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_he.dart lib/router.dart lib/shared/widgets/bottom_nav_shell.dart
git commit -m "feat: wire leaderboard into navigation"
```
