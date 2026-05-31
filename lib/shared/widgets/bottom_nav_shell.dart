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
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: l.tabHome),
          NavigationDestination(icon: const Icon(Icons.school_outlined), label: l.tabLearn),
          NavigationDestination(icon: const Icon(Icons.quiz_outlined), label: l.tabExam),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l.tabProfile),
          NavigationDestination(icon: const Icon(Icons.leaderboard_outlined), label: l.tabLeaderboard),
        ],
      ),
    );
  }
}
