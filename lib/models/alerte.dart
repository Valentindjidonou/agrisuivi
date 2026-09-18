/// Représente un rappel programmé lié à une culture.
class Alerte {
  final int? id;
  final int cultureId;
  final String titre;
  final DateTime dateEcheance;
  final bool estFaite;
  final int? notificationId;

  Alerte({
    this.id,
    required this.cultureId,
    required this.titre,
    required this.dateEcheance,
    this.estFaite = false,
    this.notificationId,
  });

  Alerte copyWith({
    int? id,
    int? cultureId,
    String? titre,
    DateTime? dateEcheance,
    bool? estFaite,
    int? notificationId,
  }) {
    return Alerte(
      id: id ?? this.id,
      cultureId: cultureId ?? this.cultureId,
      titre: titre ?? this.titre,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      estFaite: estFaite ?? this.estFaite,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cultureId': cultureId,
      'titre': titre,
      'dateEcheance': dateEcheance.toIso8601String(),
      'estFaite': estFaite ? 1 : 0,
      'notificationId': notificationId,
    };
  }

  factory Alerte.fromMap(Map<String, dynamic> map) {
    return Alerte(
      id: map['id'] as int?,
      cultureId: map['cultureId'] as int,
      titre: map['titre'] as String,
      dateEcheance: DateTime.parse(map['dateEcheance'] as String),
      estFaite: (map['estFaite'] as int) == 1,
      notificationId: map['notificationId'] as int?,
    );
  }

  bool get estEnRetard => !estFaite && dateEcheance.isBefore(DateTime.now());
}
