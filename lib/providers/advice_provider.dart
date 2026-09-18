import 'package:flutter/foundation.dart';
import '../models/conseil_saisonnier.dart';
import '../repositories/advice_repository.dart';
import '../utils/seasons.dart';

/// Filtre les conseils saisonniers par saison en cours et/ou type de culture.
class AdviceProvider extends ChangeNotifier {
  final AdviceRepository _repository = AdviceRepository();

  List<ConseilSaisonnier> _tous = [];
  String _saisonSelectionnee = Seasons.current();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String get saisonSelectionnee => _saisonSelectionnee;
  String get saisonActuelle => Seasons.current();

  List<ConseilSaisonnier> get conseilsFiltres {
    return _tous
        .where((c) =>
            c.saison == _saisonSelectionnee || c.saison == Seasons.toutesSaisons)
        .toList();
  }

  List<ConseilSaisonnier> get conseilsDuJour {
    final list = _tous
        .where((c) => c.saison == Seasons.current())
        .toList();
    return list.take(3).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tous = await _repository.getAll();
    } catch (e) {
      debugPrint('AgriSuivi: erreur de chargement des conseils ($e)');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSaison(String saison) {
    _saisonSelectionnee = saison;
    notifyListeners();
  }
}
