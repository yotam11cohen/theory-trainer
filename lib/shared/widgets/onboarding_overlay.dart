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
    const navHeight = 80.0;

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
          if (arrowX != null && arrowPointsDown)
            Positioned(
              bottom: navHeight + 4,
              left: arrowX - 16,
              child: const Icon(Icons.arrow_downward, color: Colors.white, size: 32),
            ),
          if (arrowX != null && !arrowPointsDown)
            Positioned(
              top: 120,
              left: arrowX - 16,
              child: const Icon(Icons.arrow_upward, color: Colors.white, size: 32),
            ),
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
