import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';
import '../../../domain/models/driving_exercise.dart';

class ExamSessionScreen extends ConsumerWidget {
  const ExamSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final content = exercise.content;
    final options = List<String>.from(content['options'] as List? ?? []);
    final question = content['question'] as String? ?? content['text'] as String? ?? '';
    final imageUrl = content['image_url'] as String?;

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
