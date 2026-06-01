import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/supabase_provider.dart';
import '../../../domain/models/driving_exercise.dart';
import '../../../constants.dart';
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
    final l = AppLocalizations.of(context)!;
    final examAsync = ref.watch(examProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.resultsTitle)),
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final passed = state.passed;
          if (!_bannerShown) {
            _bannerShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (passed) {
                  SoundService.playSuccess();
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref.read(supabaseServiceProvider)
                        .awardExamPassedAchievement(user.id);
                  }
                }
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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.cancel,
                        size: 80,
                        color: passed ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/app/home'),
                        child: Text(l.goHome),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(examProvider.notifier).startExam();
                          context.pushReplacement('/app/exam/session');
                        },
                        child: Text(l.tryAgain),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l.examByCategory,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _CategoryBreakdown(state: state),
                      const SizedBox(height: 16),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l.examReview,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final q = state.questions[i];
                    final chosen = state.answers[i];
                    final correct = q.correctIndex;
                    final isRight = chosen == correct;
                    return _ReviewTile(
                      index: i,
                      exercise: q,
                      chosenIndex: chosen,
                      isCorrect: isRight,
                    );
                  },
                  childCount: state.questions.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final int index;
  final DrivingExercise exercise;
  final int? chosenIndex;
  final bool isCorrect;

  const _ReviewTile({
    required this.index,
    required this.exercise,
    required this.chosenIndex,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final question = exercise.content['question'] as String? ?? exercise.text;
    final options = exercise.options;
    final correct = exercise.correctIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: isCorrect
            ? Colors.green.withOpacity(0.08)
            : Colors.red.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${index + 1}. $question',
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 8),
                if (chosenIndex != null)
                  _AnswerRow(
                    label: 'Your answer',
                    text: options[chosenIndex!],
                    color: Colors.red,
                    icon: Icons.close,
                  ),
                const SizedBox(height: 4),
                _AnswerRow(
                  label: 'Correct answer',
                  text: options[correct],
                  color: Colors.green,
                  icon: Icons.check,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final IconData icon;

  const _AnswerRow({
    required this.label,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 28),
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$label: $text',
            textDirection: TextDirection.rtl,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final ExamState state;
  const _CategoryBreakdown({required this.state});

  @override
  Widget build(BuildContext context) {
    // Tally correct/total per category slug
    final totals = <String, int>{};
    final corrects = <String, int>{};
    for (var i = 0; i < state.questions.length; i++) {
      final q = state.questions[i];
      final cat = q.content['category'] as String? ?? 'signs';
      totals[cat] = (totals[cat] ?? 0) + 1;
      if (state.answers[i] == q.correctIndex) {
        corrects[cat] = (corrects[cat] ?? 0) + 1;
      }
    }

    return Column(
      children: AppConstants.categories
          .where((cat) => totals.containsKey(cat.slug))
          .map((cat) {
        final total = totals[cat.slug] ?? 0;
        final correct = corrects[cat.slug] ?? 0;
        final progress = total == 0 ? 0.0 : correct / total;
        final isWeak = progress < 0.6;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(cat.icon, size: 18,
                  color: isWeak ? Colors.red : Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.nameHe,
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text('$correct/$total',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isWeak ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                      color: isWeak ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
