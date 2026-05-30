import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        children: AppConstants.categories
            .map((cat) => ListTile(
                  leading: Icon(cat.icon),
                  title: Text(cat.nameHe, textDirection: TextDirection.rtl),
                  subtitle: Text(
                      '${cat.nameEn} — ${(cat.examWeight * 100).round()}% of exam'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/app/learn/${cat.slug}'),
                ))
            .toList(),
      ),
    );
  }
}
