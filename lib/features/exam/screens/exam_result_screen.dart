import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';
import '../../../shared/in_app_banner.dart';
import '../../../shared/sound_service.dart';

class ExamResultScreen extends ConsumerStatefulWidget {
  const ExamResultScreen({super.key});

  @override
  ConsumerState<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends ConsumerState<ExamResultScreen> {
  bool _bannerShown = false;

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final passed = state.passed;
          if (!_bannerShown) {
            _bannerShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (passed) SoundService.playSuccess();
                InAppBanner.show(
                  context,
                  emoji: passed ? '✅' : '❌',
                  message: passed
                      ? 'You passed! ${state.score}/${state.questions.length} — great job!'
                      : 'Score: ${state.score}/${state.questions.length} — keep practicing!',
                );
              }
            });
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 80,
                  color: passed ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Passed!' : 'Not Yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${state.score} / ${state.questions.length}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/app/home'),
                  child: const Text('Go Home'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    ref.read(examProvider.notifier).startExam();
                    context.pushReplacement('/app/exam/session');
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
