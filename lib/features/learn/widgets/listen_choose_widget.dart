import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ListenChooseWidget extends StatefulWidget {
  final String text;
  final List<String> options;
  final int correctIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const ListenChooseWidget({
    super.key,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<ListenChooseWidget> createState() => _ListenChooseWidgetState();
}

class _ListenChooseWidgetState extends State<ListenChooseWidget> {
  final FlutterTts _tts = FlutterTts();
  int? _selected;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('he-IL');
    _speak();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak() => _tts.speak(widget.text);

  void _pick(int index) {
    if (_selected != null) return;
    setState(() => _selected = index);
    if (index == widget.correctIndex) {
      widget.onCorrect();
    } else {
      widget.onWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up, size: 48),
          onPressed: _speak,
        ),
        const SizedBox(height: 24),
        ...List.generate(widget.options.length, (i) {
          Color? color;
          if (_selected != null) {
            if (i == widget.correctIndex) {
              color = Colors.green;
            } else if (i == _selected) {
              color = Colors.red;
            }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color),
                onPressed: () => _pick(i),
                child: Text(widget.options[i],
                    textDirection: TextDirection.rtl),
              ),
            ),
          );
        }),
      ],
    );
  }
}
