import 'package:flutter/material.dart';

class FillBlankWidget extends StatefulWidget {
  final String prompt;
  final String answer;
  final List<String> wordBank;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const FillBlankWidget({
    super.key,
    required this.prompt,
    required this.answer,
    required this.wordBank,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  String? _selected;
  bool? _correct;

  void _pick(String word) {
    if (_correct != null) return;
    final isCorrect = word == widget.answer;
    setState(() {
      _selected = word;
      _correct = isCorrect;
    });
    if (isCorrect) {
      widget.onCorrect();
    } else {
      widget.onWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.prompt,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.wordBank.map((word) {
            Color? color;
            if (_selected == word) {
              color = _correct! ? Colors.green : Colors.red;
            } else if (_correct == false && word == widget.answer) {
              color = Colors.green;
            }
            return ActionChip(
              label: Text(word, textDirection: TextDirection.rtl),
              backgroundColor: color,
              onPressed: () => _pick(word),
            );
          }).toList(),
        ),
      ],
    );
  }
}
