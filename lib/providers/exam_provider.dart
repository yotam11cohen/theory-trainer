import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/driving_exercise.dart';
import '../data/remote/exam_service.dart';
import '../data/remote/supabase_service.dart';
import 'supabase_provider.dart';

class ExamState {
  final List<DrivingExercise> questions;
  final int currentIndex;
  final Map<int, int> answers; // question index -> chosen option index
  final bool submitted;

  const ExamState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    this.submitted = false,
  });

  int get score {
    var correct = 0;
    for (final entry in answers.entries) {
      if (entry.value == questions[entry.key].correctIndex) correct++;
    }
    return correct;
  }

  bool get passed => score >= 26;
}

class ExamNotifier extends StateNotifier<AsyncValue<ExamState>> {
  final SupabaseService _service;
  ExamNotifier(this._service) : super(const AsyncValue.loading());

  bool _isStarting = false;

  Future<void> startExam() async {
    if (_isStarting) return;
    _isStarting = true;
    state = const AsyncValue.loading();
    try {
      final pool = await _service.fetchExamPool();
      final questions = ExamService.buildExam(pool);
      state = AsyncValue.data(ExamState(
        questions: questions,
        currentIndex: 0,
        answers: {},
      ));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    } finally {
      _isStarting = false;
    }
  }

  void answer(int optionIndex) {
    final current = state.valueOrNull;
    if (current == null || current.submitted) return;
    if (current.answers.containsKey(current.currentIndex)) return;
    final newAnswers = Map<int, int>.from(current.answers)
      ..[current.currentIndex] = optionIndex;
    final nextIndex = current.currentIndex + 1;
    state = AsyncValue.data(ExamState(
      questions: current.questions,
      currentIndex: nextIndex,
      answers: newAnswers,
      submitted: nextIndex >= current.questions.length,
    ));
  }
}

final examProvider =
    StateNotifierProvider<ExamNotifier, AsyncValue<ExamState>>((ref) {
  return ExamNotifier(ref.watch(supabaseServiceProvider));
});
