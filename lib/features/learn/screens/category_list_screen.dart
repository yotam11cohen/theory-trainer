import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Category {
  final String slug;
  final String nameHe;
  final String nameEn;
  final double examWeight;
  final IconData icon;
  const _Category(this.slug, this.nameHe, this.nameEn, this.examWeight, this.icon);
}

const _categories = [
  _Category('signs', 'תמרורים ואותות', 'Signs & Signals', 0.35, Icons.traffic),
  _Category('safe_driving', 'נהיגה בטוחה', 'Safe Driving', 0.25, Icons.shield_outlined),
  _Category('laws', 'חוקים ותקנות', 'Laws & Regulations', 0.20, Icons.gavel_outlined),
  _Category('mechanics', 'מכאניקה ורכב', 'Mechanics', 0.10, Icons.build_outlined),
  _Category('first_aid', 'עזרה ראשונה', 'First Aid', 0.10, Icons.local_hospital_outlined),
];

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        children: _categories
            .map((cat) => ListTile(
                  leading: Icon(cat.icon),
                  title: Text(cat.nameHe,
                      textDirection: TextDirection.rtl),
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
