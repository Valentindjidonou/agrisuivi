import 'package:flutter/foundation.dart';
import '../models/culture.dart';
import '../repositories/culture_repository.dart';

/// Expose la liste des cultures à l'interface et gère leur CRUD.
class CultureProvider extends ChangeNotifier {
  final CultureRepository _repository = CultureRepository();

  List<Culture> _cultures = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _stadeFilter;

  List<Culture> get cultures {
    return _cultures.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.parcelle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStade = _stadeFilter == null || c.stade == _stadeFilter;
      return matchSearch && matchStade;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get stadeFilter => _stadeFilter;
  int get totalCultures => _cultures.length;
  int get culturesActives =>
      _cultures.where((c) => c.stade != 'Récolté').length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cultures = await _repository.getAll();
    } catch (e) {
      debugPrint('AgriSuivi: erreur de chargement des cultures ($e)');
    } finally {
      // Sans ce bloc, une erreur de lecture laisse le spinner tourner
      // indéfiniment et l'écran semble figé.
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStadeFilter(String? stade) {
    _stadeFilter = stade;
    notifyListeners();
  }

  Future<Culture?> getById(int id) => _repository.getById(id);

  Future<void> addCulture(Culture culture) async {
    final id = await _repository.insert(culture);
    _cultures.insert(0, culture.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateCulture(Culture culture) async {
    await _repository.update(culture);
    final index = _cultures.indexWhere((c) => c.id == culture.id);
    if (index != -1) {
      _cultures[index] = culture;
      notifyListeners();
    }
  }

  Future<void> deleteCulture(int id) async {
    await _repository.delete(id);
    _cultures.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
