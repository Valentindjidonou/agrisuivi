import '../models/activite.dart';
import '../services/database_service.dart';

/// Isole les requêtes sqflite relatives au carnet d'activités.
class ActivityRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insert(Activite activite) async {
    final db = await _dbService.database;
    final map = activite.toMap()..remove('id');
    return db.insert('activites', map);
  }

  Future<int> update(Activite activite) async {
    final db = await _dbService.database;
    return db.update(
      'activites',
      activite.toMap(),
      where: 'id = ?',
      whereArgs: [activite.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return db.delete('activites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Activite>> getByCulture(int cultureId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'activites',
      where: 'cultureId = ?',
      whereArgs: [cultureId],
      orderBy: 'date DESC',
    );
    return result.map((m) => Activite.fromMap(m)).toList();
  }
}
