import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class BottomNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BottomNavShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
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
              icon: const Icon(Icons.leaderboard_outlined), label: l.tabLeaderboard),
        ],
      ),
    );
  }
}
