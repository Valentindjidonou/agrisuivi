/// Représente un conseil pré-rempli, filtré par saison et/ou type de culture.
class ConseilSaisonnier {
  final int? id;
  final String saison; // Printemps, Été, Automne, Hiver, Toute saison
  final String typeCulture; // Type précis ou "Général"
  final String texte;
  final String titre;

  ConseilSaisonnier({
    this.id,
    required this.saison,
    required this.typeCulture,
    required this.texte,
    required this.titre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saison': saison,
      'typeCulture': typeCulture,
      'texte': texte,
      'titre': titre,
    };
  }

  factory ConseilSaisonnier.fromMap(Map<String, dynamic> map) {
    return ConseilSaisonnier(
      id: map['id'] as int?,
      saison: map['saison'] as String,
      typeCulture: map['typeCulture'] as String,
      texte: map['texte'] as String,
      titre: map['titre'] as String,
    );
  }
}
