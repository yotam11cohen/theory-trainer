import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/lessons_provider.dart';
import '../../../data/local/hive_service.dart';

class LessonListScreen extends ConsumerWidget {
  final String category;
  const LessonListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final completed = HiveService.getCompletedLessonIds();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lessons) {
          final filtered =
              lessons.where((l) => l.category == category).toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('No lessons in this category.'));
          }
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final lesson = filtered[i];
              final isDone = completed.contains(lesson.id);
              return ListTile(
                leading: Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  color: isDone ? Colors.green : null,
                ),
                title: Text(lesson.title),
                subtitle: Text(lesson.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context
                    .push('/app/learn/$category/${lesson.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
