import 'package:flutter/material.dart';

class ExercisePlayerScreen extends StatelessWidget {
  final String lessonId;
  const ExercisePlayerScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Exercises: $lessonId')));
}
