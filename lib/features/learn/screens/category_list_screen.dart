import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants.dart';
import '../../../data/local/hive_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/lessons_provider.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final lessonsAsync = ref.watch(lessonsProvider);
    final completed = HiveService.getCompletedLessonIds();

    return Scaffold(
      appBar: AppBar(title: Text(l.learnTitle)),
      body: lessonsAsync.when(
        loading: () => ListView(
          children: AppConstants.categories
              .map((cat) => _CategoryTile(cat: cat, total: null, completedCount: 0))
              .toList(),
        ),
        error: (_, __) => ListView(
          children: AppConstants.categories
              .map((cat) => _CategoryTile(cat: cat, total: null, completedCount: 0))
              .toList(),
        ),
        data: (lessons) => ListView(
          children: AppConstants.categories.map((cat) {
            final catLessons = lessons.where((l) => l.category == cat.slug).toList();
            final completedCount =
                catLessons.where((l) => completed.contains(l.id)).length;
            return _CategoryTile(
              cat: cat,
              total: catLessons.length,
              completedCount: completedCount,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final AppCategory cat;
  final int? total;
  final int completedCount;

  const _CategoryTile({
    required this.cat,
    required this.total,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = total != null && total! > 0;
    final progress = hasData ? completedCount / total! : 0.0;

    return ListTile(
      leading: Icon(cat.icon),
      title: Text(cat.nameHe, textDirection: TextDirection.rtl),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${cat.nameEn} — ${(cat.examWeight * 100).round()}% of exam'),
          if (hasData) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 2),
            Text(
              '$completedCount / $total lessons',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      isThreeLine: hasData,
      onTap: () => context.push('/app/learn/${cat.slug}'),
    );
  }
}
