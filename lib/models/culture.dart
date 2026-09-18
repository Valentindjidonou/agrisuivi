/// Représente une culture suivie par l'exploitant, sur une parcelle donnée.
class Culture {
  final int? id;
  final String nom;
  final String type;
  final DateTime dateSemis;
  final String stade;
  final double superficie; // en hectares
  final String parcelle;
  final String note;
  final String? photoPath;

  Culture({
    this.id,
    required this.nom,
    required this.type,
    required this.dateSemis,
    required this.stade,
    required this.superficie,
    required this.parcelle,
    this.note = '',
    this.photoPath,
  });

  /// Liste des stades de croissance possibles, dans l'ordre chronologique.
  static const List<String> stades = [
    'Semis',
    'Levée',
    'Croissance',
    'Floraison',
    'Maturation',
    'Récolté',
  ];

  /// Types de cultures courants proposés par défaut (l'utilisateur peut saisir autre chose).
  static const List<String> typesCourants = [
    'Maïs',
    'Riz',
    'Manioc',
    'Igname',
    'Tomate',
    'Haricot',
    'Arachide',
    'Piment',
    'Oignon',
    'Autre',
  ];

  Culture copyWith({
    int? id,
    String? nom,
    String? type,
    DateTime? dateSemis,
    String? stade,
    double? superficie,
    String? parcelle,
    String? note,
    String? photoPath,
    bool clearPhoto = false,
  }) {
    return Culture(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      dateSemis: dateSemis ?? this.dateSemis,
      stade: stade ?? this.stade,
      superficie: superficie ?? this.superficie,
      parcelle: parcelle ?? this.parcelle,
      note: note ?? this.note,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'dateSemis': dateSemis.toIso8601String(),
      'stade': stade,
      'superficie': superficie,
      'parcelle': parcelle,
      'note': note,
      'photoPath': photoPath,
    };
  }

  factory Culture.fromMap(Map<String, dynamic> map) {
    return Culture(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      type: map['type'] as String,
      dateSemis: DateTime.parse(map['dateSemis'] as String),
      stade: map['stade'] as String,
      superficie: (map['superficie'] as num).toDouble(),
      parcelle: map['parcelle'] as String,
      note: (map['note'] as String?) ?? '',
      photoPath: map['photoPath'] as String?,
    );
  }

  bool get estRecoltee => stade == 'Récolté';
}
