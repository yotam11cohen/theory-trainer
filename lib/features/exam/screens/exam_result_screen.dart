import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';

class ExamResultScreen extends ConsumerWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(examProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final passed = state.passed;
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
                  onPressed: () async {
                    await ref.read(examProvider.notifier).startExam();
                    if (context.mounted) {
                      context.pushReplacement('/app/exam/session');
                    }
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
