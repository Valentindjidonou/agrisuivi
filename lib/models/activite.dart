/// Représente une action réalisée sur une culture (carnet d'activités).
class Activite {
  final int? id;
  final int cultureId;
  final String type; // Arrosage, Traitement, Désherbage, Récolte
  final DateTime date;
  final String remarque;

  Activite({
    this.id,
    required this.cultureId,
    required this.type,
    required this.date,
    this.remarque = '',
  });

  static const List<String> types = [
    'Arrosage',
    'Traitement',
    'Désherbage',
    'Récolte',
  ];

  Activite copyWith({
    int? id,
    int? cultureId,
    String? type,
    DateTime? date,
    String? remarque,
  }) {
    return Activite(
      id: id ?? this.id,
      cultureId: cultureId ?? this.cultureId,
      type: type ?? this.type,
      date: date ?? this.date,
      remarque: remarque ?? this.remarque,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cultureId': cultureId,
      'type': type,
      'date': date.toIso8601String(),
      'remarque': remarque,
    };
  }

  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      id: map['id'] as int?,
      cultureId: map['cultureId'] as int,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      remarque: (map['remarque'] as String?) ?? '',
    );
  }
}
