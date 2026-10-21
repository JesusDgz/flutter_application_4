import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_4/main.dart';

void main() {
  testWidgets('shows the encrypted JSON storage actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Guardar JSON cifrado'), findsOneWidget);
    expect(find.text('Leer y descifrar JSON'), findsOneWidget);
    expect(find.byKey(const Key('json-editor')), findsOneWidget);
  });
}
