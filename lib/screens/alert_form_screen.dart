import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerte.dart';
import '../models/culture.dart';
import '../providers/alert_provider.dart';

/// Formulaire de programmation d'une alerte / rappel local pour une culture.
class AlertFormScreen extends StatefulWidget {
  final Culture culture;
  const AlertFormScreen({super.key, required this.culture});

  @override
  State<AlertFormScreen> createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends State<AlertFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _heure = const TimeOfDay(hour: 8, minute: 0);
  bool _saving = false;

  @override
  void dispose() {
    _titreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _pickHeure() async {
    final result = await showTimePicker(context: context, initialTime: _heure);
    if (result != null) setState(() => _heure = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final dateEcheance =
          DateTime(_date.year, _date.month, _date.day, _heure.hour, _heure.minute);

      final alerte = Alerte(
        cultureId: widget.culture.id!,
        titre: _titreController.text.trim(),
        dateEcheance: dateEcheance,
      );

      await context.read<AlertProvider>().addAlerte(alerte, nomCulture: widget.culture.nom);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle alerte')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            TextFormField(
              controller: _titreController,
              decoration: InputDecoration(
                labelText: 'Titre du rappel *',
                hintText: 'Ex. Traiter ${widget.culture.nom} contre les nuisibles',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date *'),
                      child: Text('${_date.day}/${_date.month}/${_date.year}'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickHeure,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Heure *'),
                      child: Text(_heure.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Programmer le rappel'),
            ),
          ],
        ),
      ),
    );
  }
}
