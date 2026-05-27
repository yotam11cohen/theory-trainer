import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageQuestionWidget extends StatefulWidget {
  final String imageUrl;
  final String question;
  final List<String> options;
  final int correctIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const ImageQuestionWidget({
    super.key,
    required this.imageUrl,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<ImageQuestionWidget> createState() => _ImageQuestionWidgetState();
}

class _ImageQuestionWidgetState extends State<ImageQuestionWidget> {
  int? _selected;

  void _pick(int i) {
    if (_selected != null) return;
    setState(() => _selected = i);
    if (i == widget.correctIndex) {
      widget.onCorrect();
    } else {
      widget.onWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CachedNetworkImage(imageUrl: widget.imageUrl, height: 160),
        const SizedBox(height: 12),
        Text(
          widget.question,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
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
