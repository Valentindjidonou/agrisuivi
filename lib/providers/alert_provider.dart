import 'package:flutter/foundation.dart';
import '../models/alerte.dart';
import '../repositories/alert_repository.dart';
import '../services/notification_service.dart';

/// Gère les alertes/rappels, ainsi que la programmation des notifications locales.
class AlertProvider extends ChangeNotifier {
  final AlertRepository _repository = AlertRepository();
  final NotificationService _notificationService = NotificationService.instance;

  final Map<int, List<Alerte>> _alertesParCulture = {};
  List<Alerte> _prochaines = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Alerte> get prochaines => _prochaines;

  List<Alerte> forCulture(int cultureId) => _alertesParCulture[cultureId] ?? [];

  Future<void> loadForCulture(int cultureId) async {
    _alertesParCulture[cultureId] = await _repository.getByCulture(cultureId);
    notifyListeners();
  }

  Future<void> loadUpcoming() async {
    _isLoading = true;
    notifyListeners();
    try {
      _prochaines = await _repository.getUpcoming();
    } catch (e) {
      debugPrint('AgriSuivi: erreur de chargement des alertes ($e)');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAlerte(Alerte alerte, {required String nomCulture}) async {
    // La notification est programmée en best-effort : si le système refuse
    // (permission non accordée, alarmes exactes désactivées, plateforme non
    // supportée…), l'alerte doit malgré tout être enregistrée en base.
    int? notifId;
    try {
      notifId = await _notificationService.schedule(
        titre: alerte.titre,
        corps: 'Rappel pour "$nomCulture"',
        dateEcheance: alerte.dateEcheance,
      );
    } catch (e) {
      debugPrint('AgriSuivi: notification non programmée ($e)');
    }

    final id = await _repository.insert(alerte.copyWith(notificationId: notifId));
    final saved = alerte.copyWith(id: id, notificationId: notifId);
    final list = _alertesParCulture.putIfAbsent(alerte.cultureId, () => []);
    list.add(saved);
    list.sort((a, b) => a.dateEcheance.compareTo(b.dateEcheance));
    await loadUpcoming();
    notifyListeners();
  }

  Future<void> toggleFaite(Alerte alerte) async {
    final updated = alerte.copyWith(estFaite: !alerte.estFaite);
    await _repository.update(updated);
    if (updated.estFaite) {
      try {
        await _notificationService.cancel(updated.notificationId);
      } catch (e) {
        debugPrint('AgriSuivi: annulation de notification impossible ($e)');
      }
    }
    final list = _alertesParCulture[alerte.cultureId];
    if (list != null) {
      final index = list.indexWhere((a) => a.id == alerte.id);
      if (index != -1) list[index] = updated;
    }
    await loadUpcoming();
    notifyListeners();
  }

  Future<void> deleteAlerte(Alerte alerte) async {
    await _repository.delete(alerte.id!);
    try {
      await _notificationService.cancel(alerte.notificationId);
    } catch (e) {
      debugPrint('AgriSuivi: annulation de notification impossible ($e)');
    }
    _alertesParCulture[alerte.cultureId]?.removeWhere((a) => a.id == alerte.id);
    await loadUpcoming();
    notifyListeners();
  }
}
