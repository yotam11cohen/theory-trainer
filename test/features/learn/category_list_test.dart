import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/features/learn/screens/category_list_screen.dart';

void main() {
  testWidgets('CategoryListScreen shows 5 categories', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CategoryListScreen()),
    );
    // 5 category tiles
    expect(find.byType(ListTile), findsNWidgets(5));
  });
}
