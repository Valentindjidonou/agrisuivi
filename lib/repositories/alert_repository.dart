import '../models/alerte.dart';
import '../services/database_service.dart';

/// Isole les requêtes sqflite relatives aux alertes / rappels.
class AlertRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insert(Alerte alerte) async {
    final db = await _dbService.database;
    final map = alerte.toMap()..remove('id');
    return db.insert('alertes', map);
  }

  Future<int> update(Alerte alerte) async {
    final db = await _dbService.database;
    return db.update(
      'alertes',
      alerte.toMap(),
      where: 'id = ?',
      whereArgs: [alerte.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return db.delete('alertes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Alerte>> getByCulture(int cultureId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'alertes',
      where: 'cultureId = ?',
      whereArgs: [cultureId],
      orderBy: 'dateEcheance ASC',
    );
    return result.map((m) => Alerte.fromMap(m)).toList();
  }

  /// Alertes non terminées, toutes cultures confondues, triées par échéance.
  Future<List<Alerte>> getUpcoming({int limit = 20}) async {
    final db = await _dbService.database;
    final result = await db.query(
      'alertes',
      where: 'estFaite = 0',
      orderBy: 'dateEcheance ASC',
      limit: limit,
    );
    return result.map((m) => Alerte.fromMap(m)).toList();
  }

  Future<int> countUpcoming() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM alertes WHERE estFaite = 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
