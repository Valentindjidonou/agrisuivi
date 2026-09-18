import '../models/conseil_saisonnier.dart';
import '../services/database_service.dart';

/// Isole les requêtes sqflite relatives aux conseils saisonniers.
class AdviceRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<List<ConseilSaisonnier>> getAll() async {
    final db = await _dbService.database;
    final result = await db.query('conseils', orderBy: 'saison, typeCulture');
    return result.map((m) => ConseilSaisonnier.fromMap(m)).toList();
  }

  Future<List<ConseilSaisonnier>> getBySaison(String saison) async {
    final db = await _dbService.database;
    final result = await db.query(
      'conseils',
      where: 'saison = ? OR saison = ?',
      whereArgs: [saison, 'Toute saison'],
    );
    return result.map((m) => ConseilSaisonnier.fromMap(m)).toList();
  }
}
