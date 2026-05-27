import 'package:flutter/material.dart';
import '../../../domain/models/driving_exercise.dart';
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

  void _onCorrect() => setState(() {
        _answered = true;
        _correct++;
      });

  void _onWrong() => setState(() => _answered = true);

  void _next() {
    if (_index + 1 >= widget.exercises.length) {
      final score = (_correct / widget.exercises.length * 100).round();
      widget.onComplete(score);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
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
    final c = ex.content;
    return switch (ex.type) {
      ExerciseType.vocabulary => VocabularyCard(
          term: c['term'] as String,
          definition: c['definition'] as String,
          imageUrl: c['image_url'] as String?,
          // Vocabulary cards are informational — mark correct on first flip
          onFlip: _onCorrect,
        ),
      ExerciseType.listenChoose => ListenChooseWidget(
          text: c['text'] as String,
          options: List<String>.from(c['options'] as List),
          correctIndex: c['correct_index'] as int,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
      ExerciseType.completePhrase => FillBlankWidget(
          prompt: c['prompt'] as String,
          answer: c['answer'] as String,
          wordBank: List<String>.from(c['word_bank'] as List),
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
      ExerciseType.imageQuestion => ImageQuestionWidget(
          imageUrl: c['image_url'] as String,
          question: c['question'] as String,
          options: List<String>.from(c['options'] as List),
          correctIndex: c['correct_index'] as int,
          onCorrect: _onCorrect,
          onWrong: _onWrong,
        ),
    };
  }
}
