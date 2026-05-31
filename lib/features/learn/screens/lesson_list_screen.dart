import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/driving_lesson.dart';
import '../../../providers/lessons_provider.dart';
import '../../../data/local/hive_service.dart';

bool _isUnlocked(
  DrivingLesson lesson,
  List<DrivingLesson> categoryLessons,
  Set<String> completedIds,
) {
  final sorted = [...categoryLessons]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final idx = sorted.indexWhere((l) => l.id == lesson.id);
  if (idx <= 0) return true;
  return completedIds.contains(sorted[idx - 1].id);
}

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
          final filtered = lessons
              .where((l) => l.category == category)
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          if (filtered.isEmpty) {
            return const Center(child: Text('No lessons in this category.'));
          }
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final lesson = filtered[i];
              final isDone = completed.contains(lesson.id);
              final unlocked = _isUnlocked(lesson, filtered, completed);
              return ListTile(
                leading: Icon(
                  isDone
                      ? Icons.check_circle
                      : unlocked
                          ? Icons.circle_outlined
                          : Icons.lock_outline,
                  color: isDone
                      ? Colors.green
                      : unlocked
                          ? null
                          : Colors.grey,
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(color: unlocked ? null : Colors.grey),
                ),
                subtitle: Text(
                  lesson.description,
                  style: TextStyle(color: unlocked ? null : Colors.grey),
                ),
                trailing: unlocked ? const Icon(Icons.chevron_right) : null,
                onTap: unlocked
                    ? () => context.push('/app/learn/$category/${lesson.id}')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
