import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Service central d'accès à la base SQLite locale (sqflite).
/// Toutes les requêtes des repositories transitent par ce singleton.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;
  static Future<Database>? _opening;
  static bool _ffiConfigured = false;

  /// Le plugin `sqflite` n'a pas d'implémentation native sur Windows/macOS/
  /// Linux : sans ce basculement vers `sqflite_common_ffi`, TOUTES les
  /// opérations en base échouent silencieusement sur desktop.
  void _configureFactoryForPlatform() {
    if (_ffiConfigured || kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiConfigured = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _configureFactoryForPlatform();
    // Empêche l'ouverture simultanée de plusieurs connexions si plusieurs
    // écrans démarrent en même temps (Accueil, Cultures, Conseils au lancement).
    _opening ??= _initDatabase();
    _database = await _opening;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, 'agrisuivi.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cultures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        dateSemis TEXT NOT NULL,
        stade TEXT NOT NULL,
        superficie REAL NOT NULL,
        parcelle TEXT NOT NULL,
        note TEXT,
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultureId INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        remarque TEXT,
        FOREIGN KEY (cultureId) REFERENCES cultures (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE alertes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultureId INTEGER NOT NULL,
        titre TEXT NOT NULL,
        dateEcheance TEXT NOT NULL,
        estFaite INTEGER NOT NULL DEFAULT 0,
        notificationId INTEGER,
        FOREIGN KEY (cultureId) REFERENCES cultures (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE conseils (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saison TEXT NOT NULL,
        typeCulture TEXT NOT NULL,
        titre TEXT NOT NULL,
        texte TEXT NOT NULL
      )
    ''');

    await _seedConseils(db);
  }

  /// Base de conseils pré-remplie lors de la première ouverture de l'application.
  Future<void> _seedConseils(Database db) async {
    final conseils = <Map<String, dynamic>>[
      // --- Printemps ---
      {
        'saison': 'Printemps',
        'typeCulture': 'Général',
        'titre': 'Préparer le sol',
        'texte':
            'Ameublissez la terre en profondeur et retirez les mauvaises herbes avant le semis pour favoriser une bonne levée.'
      },
      {
        'saison': 'Printemps',
        'typeCulture': 'Maïs',
        'titre': 'Semis du maïs',
        'texte':
            'Semez lorsque le sol est réchauffé et suffisamment humide, en respectant un espacement d\'environ 25 cm entre les plants.'
      },
      {
        'saison': 'Printemps',
        'typeCulture': 'Tomate',
        'titre': 'Repiquage des tomates',
        'texte':
            'Repiquez les jeunes plants après les dernières gelées et installez un tuteur dès la plantation.'
      },
      {
        'saison': 'Printemps',
        'typeCulture': 'Riz',
        'titre': 'Pépinière de riz',
        'texte':
            'Préparez la pépinière sur un sol bien nivelé et maintenu humide pendant toute la phase de germination.'
      },
      // --- Été ---
      {
        'saison': 'Été',
        'typeCulture': 'Général',
        'titre': 'Arrosage en période chaude',
        'texte':
            'Arrosez tôt le matin ou en fin de journée pour limiter l\'évaporation et économiser l\'eau.'
      },
      {
        'saison': 'Été',
        'typeCulture': 'Maïs',
        'titre': 'Surveiller la floraison',
        'texte':
            'La floraison est une période critique : assurez un apport en eau régulier pour garantir une bonne fécondation des épis.'
      },
      {
        'saison': 'Été',
        'typeCulture': 'Tomate',
        'titre': 'Prévenir le mildiou',
        'texte':
            'Évitez de mouiller le feuillage et aérez les plants pour réduire les risques de maladies fongiques.'
      },
      {
        'saison': 'Été',
        'typeCulture': 'Piment',
        'titre': 'Récolte échelonnée',
        'texte':
            'Récoltez régulièrement les piments arrivés à maturité pour stimuler la production de nouveaux fruits.'
      },
      {
        'saison': 'Été',
        'typeCulture': 'Arachide',
        'titre': 'Désherbage de l\'arachide',
        'texte':
            'Désherbez avant la formation des gousses en terre, car un désherbage tardif peut abîmer les racines.'
      },
      // --- Automne ---
      {
        'saison': 'Automne',
        'typeCulture': 'Général',
        'titre': 'Préparer la récolte',
        'texte':
            'Vérifiez régulièrement le stade de maturité des cultures et préparez le matériel de récolte et de stockage.'
      },
      {
        'saison': 'Automne',
        'typeCulture': 'Manioc',
        'titre': 'Récolte du manioc',
        'texte':
            'Le manioc peut être récolté progressivement selon les besoins ; les racines se conservent mal une fois déterrées.'
      },
      {
        'saison': 'Automne',
        'typeCulture': 'Igname',
        'titre': 'Récolte de l\'igname',
        'texte':
            'Récoltez avec précaution pour ne pas blesser les tubercules, ce qui favoriserait leur pourrissement au stockage.'
      },
      {
        'saison': 'Automne',
        'typeCulture': 'Haricot',
        'titre': 'Séchage des haricots',
        'texte':
            'Laissez sécher les gousses sur pied avant récolte, puis stockez-les dans un endroit sec et aéré.'
      },
      // --- Hiver ---
      {
        'saison': 'Hiver',
        'typeCulture': 'Général',
        'titre': 'Entretien des parcelles',
        'texte':
            'Profitez de la saison creuse pour entretenir les outils, amender le sol et planifier les cultures à venir.'
      },
      {
        'saison': 'Hiver',
        'typeCulture': 'Oignon',
        'titre': 'Culture de l\'oignon',
        'texte':
            'L\'oignon apprécie les températures fraîches ; surveillez l\'humidité du sol sans excès pour éviter le pourrissement.'
      },
      {
        'saison': 'Hiver',
        'typeCulture': 'Général',
        'titre': 'Rotation des cultures',
        'texte':
            'Planifiez une rotation des cultures sur vos parcelles afin de préserver la fertilité du sol pour la saison prochaine.'
      },
      // --- Toute saison ---
      {
        'saison': 'Toute saison',
        'typeCulture': 'Général',
        'titre': 'Observer régulièrement',
        'texte':
            'Inspectez vos cultures au moins deux fois par semaine pour repérer tôt les signes de maladies ou de ravageurs.'
      },
      {
        'saison': 'Toute saison',
        'typeCulture': 'Général',
        'titre': 'Tenir un carnet à jour',
        'texte':
            'Notez systématiquement vos arrosages et traitements : cela aide à comprendre l\'évolution de chaque parcelle.'
      },
    ];

    for (final c in conseils) {
      await db.insert('conseils', c);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
