import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/main.dart';

void main() {
  testWidgets('Exibe título e campo de busca da Pokédex', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MyApp()));

    // Verifica se o título aparece no AppBar
    expect(find.text('Pokédex'), findsOneWidget);

    // Verifica se o campo de busca aparece
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Buscar Pokémon (nome ou número)'), findsOneWidget);
  });
}
