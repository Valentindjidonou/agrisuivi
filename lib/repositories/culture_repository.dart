import '../models/culture.dart';
import '../services/database_service.dart';

/// Isole les requêtes sqflite relatives aux cultures du reste de l'application.
class CultureRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insert(Culture culture) async {
    final db = await _dbService.database;
    final map = culture.toMap()..remove('id');
    return db.insert('cultures', map);
  }

  Future<int> update(Culture culture) async {
    final db = await _dbService.database;
    return db.update(
      'cultures',
      culture.toMap(),
      where: 'id = ?',
      whereArgs: [culture.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return db.delete('cultures', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Culture>> getAll() async {
    final db = await _dbService.database;
    final result = await db.query('cultures', orderBy: 'dateSemis DESC');
    return result.map((m) => Culture.fromMap(m)).toList();
  }

  Future<Culture?> getById(int id) async {
    final db = await _dbService.database;
    final result = await db.query('cultures', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Culture.fromMap(result.first);
  }

  Future<int> countActives() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM cultures WHERE stade != 'Récolté'",
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
