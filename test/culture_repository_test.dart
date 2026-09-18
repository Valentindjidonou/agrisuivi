import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:agrisuivi/models/culture.dart';
import 'package:agrisuivi/repositories/culture_repository.dart';

/// Test unitaire du repository Culture : ajout puis lecture d'une culture en base.
/// Utilise sqflite_common_ffi pour exécuter sqflite en environnement de test (desktop/CI).
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('ajoute une culture puis la retrouve en base', () async {
    final repository = CultureRepository();

    final culture = Culture(
      nom: 'Maïs parcelle A',
      type: 'Maïs',
      dateSemis: DateTime(2026, 3, 15),
      stade: 'Semis',
      superficie: 1.5,
      parcelle: 'A',
      note: 'Test',
    );

    final id = await repository.insert(culture);
    final retrouvee = await repository.getById(id);

    expect(retrouvee, isNotNull);
    expect(retrouvee!.nom, 'Maïs parcelle A');
    expect(retrouvee.type, 'Maïs');
    expect(retrouvee.superficie, 1.5);
    expect(retrouvee.stade, 'Semis');
  });
}
