import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';

class ExamIntroScreen extends ConsumerWidget {
  const ExamIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = [
      ('Signs & Signals', '35%'),
      ('Safe Driving', '25%'),
      ('Laws & Regulations', '20%'),
      ('Mechanics', '10%'),
      ('First Aid', '10%'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Theory Exam')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('30 questions • Pass: 26/30',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Table(
              border: TableBorder.all(color: Colors.white24),
              children: [
                const TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                ...rows.map((r) => TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(r.$1)),
                      Padding(padding: const EdgeInsets.all(8), child: Text(r.$2)),
                    ])),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await ref.read(examProvider.notifier).startExam();
                if (context.mounted) context.push('/app/exam/session');
              },
              child: const Text('Start Exam'),
            ),
          ],
        ),
      ),
    );
  }
}
