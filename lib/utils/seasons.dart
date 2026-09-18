/// Détermine la saison en cours (hémisphère nord, calendrier météorologique)
/// afin de filtrer les conseils saisonniers pertinents.
class Seasons {
  static const String printemps = 'Printemps';
  static const String ete = 'Été';
  static const String automne = 'Automne';
  static const String hiver = 'Hiver';
  static const String toutesSaisons = 'Toute saison';

  static const List<String> toutes = [printemps, ete, automne, hiver];

  static String current({DateTime? at}) {
    final month = (at ?? DateTime.now()).month;
    if (month == 12 || month == 1 || month == 2) return hiver;
    if (month >= 3 && month <= 5) return printemps;
    if (month >= 6 && month <= 8) return ete;
    return automne;
  }

  static String emoji(String saison) {
    switch (saison) {
      case printemps:
        return '🌱';
      case ete:
        return '☀️';
      case automne:
        return '🍂';
      case hiver:
        return '❄️';
      default:
        return '🌾';
    }
  }
}
