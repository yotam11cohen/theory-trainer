import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClearedApp extends ConsumerWidget {
  const ClearedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      title: 'Cleared — Theory',
      home: Scaffold(body: Center(child: Text('Cleared'))),
    );
  }
}
