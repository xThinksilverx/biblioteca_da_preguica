import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca_da_preguica/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaDaPreguicaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
