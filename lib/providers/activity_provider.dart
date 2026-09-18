import 'package:flutter/foundation.dart';
import '../models/activite.dart';
import '../repositories/activity_repository.dart';

/// Gère les activités (arrosage, traitement, désherbage, récolte) d'une culture.
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  final Map<int, List<Activite>> _activitesParCulture = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Activite> forCulture(int cultureId) =>
      _activitesParCulture[cultureId] ?? [];

  Future<void> loadForCulture(int cultureId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _activitesParCulture[cultureId] = await _repository.getByCulture(cultureId);
    } catch (e) {
      debugPrint('AgriSuivi: erreur de chargement des activités ($e)');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivite(Activite activite) async {
    final id = await _repository.insert(activite);
    final list = _activitesParCulture.putIfAbsent(activite.cultureId, () => []);
    list.insert(0, activite.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteActivite(int id, int cultureId) async {
    await _repository.delete(id);
    _activitesParCulture[cultureId]?.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
