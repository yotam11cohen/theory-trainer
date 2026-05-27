import 'package:flutter/material.dart';

class LessonListScreen extends StatelessWidget {
  final String category;
  const LessonListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Lessons: $category')));
}
