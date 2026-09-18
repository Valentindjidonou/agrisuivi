import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activite.dart';
import '../providers/activity_provider.dart';

/// Formulaire d'ajout d'une activité (arrosage, traitement, désherbage, récolte)
/// pour une culture donnée.
class ActivityFormScreen extends StatefulWidget {
  final int cultureId;
  const ActivityFormScreen({super.key, required this.cultureId});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  String _type = Activite.types.first;
  DateTime _date = DateTime.now();
  final _remarqueController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _remarqueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final activite = Activite(
        cultureId: widget.cultureId,
        type: _type,
        date: _date,
        remarque: _remarqueController.text.trim(),
      );
      await context.read<ActivityProvider>().addActivite(activite);
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
      appBar: AppBar(title: const Text('Nouvelle activité')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type d\'activité *'),
            items: Activite.types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date *'),
              child: Text('${_date.day}/${_date.month}/${_date.year}'),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _remarqueController,
            decoration: const InputDecoration(labelText: 'Remarque (optionnel)'),
            maxLines: 3,
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
                : const Text('Enregistrer l\'activité'),
          ),
        ],
      ),
    );
  }
}
