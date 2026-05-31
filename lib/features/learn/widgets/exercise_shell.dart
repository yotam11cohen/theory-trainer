import 'package:flutter/material.dart';
import '../../../domain/models/driving_exercise.dart';
import '../../../shared/sound_service.dart';
import 'vocabulary_card.dart';
import 'listen_choose_widget.dart';
import 'fill_blank_widget.dart';
import 'image_question_widget.dart';

class ExerciseShell extends StatefulWidget {
  final List<DrivingExercise> exercises;
  final void Function(int score) onComplete;

  const ExerciseShell({
    super.key,
    required this.exercises,
    required this.onComplete,
  });

  @override
  State<ExerciseShell> createState() => _ExerciseShellState();
}

class _ExerciseShellState extends State<ExerciseShell> {
  int _index = 0;
  int _correct = 0;
  bool _answered = false;
  bool? _answeredCorrect;

  void _onCorrect() => setState(() {
        _answered = true;
        _answeredCorrect = true;
        _correct++;
      });

  void _onWrong() {
    SoundService.playFail();
    setState(() {
      _answered = true;
      _answeredCorrect = false;
    });
  }

  void _next() {
    if (_index + 1 >= widget.exercises.length) {
      final score = (_correct / widget.exercises.length * 100).round();
      widget.onComplete(score);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _answeredCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercises[_index];
    final total = widget.exercises.length;

    return Column(
      children: [
        LinearProgressIndicator(value: (_index + 1) / total),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text('${_index + 1} / $total'),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildExercise(ex),
          ),
        ),
        if (_answered && ex.explanation != null && ex.explanation!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: _answeredCorrect == true
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _answeredCorrect == true
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: _answeredCorrect == true
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ex.explanation!,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                    _index + 1 >= total ? 'Finish' : 'Next'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExercise(DrivingExercise ex) {
    return switch (ex.type) {
      ExerciseType.vocabulary => VocabularyCard(
          key: ValueKey(ex.id),
          term: ex.term,
          definition: ex.definition,
          imageUrl: ex.imageUrl,
          onFlip: _onCorrect,
        ),
      ExerciseType.listenChoose => ListenChooseWidget(
          key: ValueKey(ex.id),
          text: ex.text,
          options: ex.options,
          correctIndex: ex.correctIndex,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
      ExerciseType.completePhrase => FillBlankWidget(
          key: ValueKey(ex.id),
          prompt: ex.prompt,
          answer: ex.answer,
          wordBank: ex.wordBank,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
      ExerciseType.imageQuestion => ImageQuestionWidget(
          key: ValueKey(ex.id),
          imageUrl: ex.imageUrl!,
          question: ex.question,
          options: ex.options,
          correctIndex: ex.correctIndex,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
    };
  }
}
