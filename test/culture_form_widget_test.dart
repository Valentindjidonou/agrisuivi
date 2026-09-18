import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:agrisuivi/providers/culture_provider.dart';
import 'package:agrisuivi/screens/culture_form_screen.dart';

/// Test de widget : validation des champs obligatoires du formulaire d'ajout de culture.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('affiche des erreurs si les champs obligatoires sont vides',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CultureProvider(),
        child: const MaterialApp(home: CultureFormScreen()),
      ),
    );

    await tester.tap(find.text('Ajouter la culture'));
    await tester.pumpAndSettle();

    expect(find.text('Champ obligatoire'), findsWidgets);
  });
}
