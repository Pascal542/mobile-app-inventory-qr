// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importa el main.dart del proyecto con el nombre actualizado
import 'package:mobile_app_inventory_qr/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Construye nuestra app y desencadena un frame
    await tester.pumpWidget(const MyApp());

    // Verifica que nuestro contador inicia en 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Toca el icono '+' y desencadena un frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que nuestro contador haya incrementado
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
