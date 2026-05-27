import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VocabularyCard extends StatefulWidget {
  final String term;
  final String definition;
  final String? imageUrl;
  /// Called when the card is flipped (first tap). Used by ExerciseShell
  /// to mark a vocabulary exercise as "answered" without a right/wrong score.
  final VoidCallback? onFlip;

  const VocabularyCard({
    super.key,
    required this.term,
    required this.definition,
    this.imageUrl,
    this.onFlip,
  });

  @override
  State<VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends State<VocabularyCard> {
  bool _flipped = false;

  void _handleTap() {
    if (!_flipped) {
      setState(() => _flipped = true);
      widget.onFlip?.call();
    } else {
      setState(() => _flipped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _flipped
            ? _CardFace(
                key: const ValueKey('back'),
                text: widget.definition,
                imageUrl: widget.imageUrl,
              )
            : _CardFace(key: const ValueKey('front'), text: widget.term),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final String? imageUrl;
  const _CardFace({super.key, required this.text, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageUrl != null) ...[
                CachedNetworkImage(imageUrl: imageUrl!, height: 120),
                const SizedBox(height: 16),
              ],
              Text(
                text,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              const Text('Tap to flip',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
