import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';
import '../../../domain/models/driving_exercise.dart';

class ExamSessionScreen extends ConsumerStatefulWidget {
  const ExamSessionScreen({super.key});

  @override
  ConsumerState<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends ConsumerState<ExamSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(examProvider);
      if (state is AsyncLoading) {
        ref.read(examProvider.notifier).startExam();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examProvider);

    return Scaffold(
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state.submitted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pushReplacement('/app/exam/result');
            });
            return const Center(child: CircularProgressIndicator());
          }
          final q = state.questions[state.currentIndex];
          return SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                    value: (state.currentIndex + 1) / state.questions.length),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                      'Question ${state.currentIndex + 1} of ${state.questions.length}'),
                ),
                Expanded(child: _QuestionCard(exercise: q)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final DrivingExercise exercise;
  const _QuestionCard({required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = exercise.options;
    final question = exercise.content['question'] as String? ?? exercise.text;
    final imageUrl = exercise.imageUrl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null) ...[
            CachedNetworkImage(imageUrl: imageUrl, height: 140),
            const SizedBox(height: 12),
          ],
          Text(question,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ...List.generate(options.length, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(examProvider.notifier).answer(i),
                  child: Text(options[i], textDirection: TextDirection.rtl),
                ),
              )),
        ],
      ),
    );
  }
}
