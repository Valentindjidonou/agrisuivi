import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/culture.dart';
import '../providers/culture_provider.dart';
import '../theme/app_theme.dart';

/// Formulaire de création ou modification d'une culture.
/// Champs : type de culture, date de semis, stade actuel, superficie, parcelle,
/// note libre et photo optionnelle (image_picker).
class CultureFormScreen extends StatefulWidget {
  final Culture? culture;
  const CultureFormScreen({super.key, this.culture});

  @override
  State<CultureFormScreen> createState() => _CultureFormScreenState();
}

class _CultureFormScreenState extends State<CultureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _parcelleController;
  late TextEditingController _superficieController;
  late TextEditingController _noteController;

  String _type = Culture.typesCourants.first;
  String _stade = Culture.stades.first;
  DateTime _dateSemis = DateTime.now();
  String? _photoPath;
  bool _saving = false;

  bool get _isEdition => widget.culture != null;

  @override
  void initState() {
    super.initState();
    final c = widget.culture;
    _nomController = TextEditingController(text: c?.nom ?? '');
    _parcelleController = TextEditingController(text: c?.parcelle ?? '');
    _superficieController = TextEditingController(text: c != null ? c.superficie.toString() : '');
    _noteController = TextEditingController(text: c?.note ?? '');
    if (c != null) {
      _type = Culture.typesCourants.contains(c.type) ? c.type : Culture.typesCourants.last;
      _stade = c.stade;
      _dateSemis = c.dateSemis;
      _photoPath = c.photoPath;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _parcelleController.dispose();
    _superficieController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _dateSemis,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) setState(() => _dateSemis = result);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) setState(() => _photoPath = image.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return; // évite un double-appui pendant l'enregistrement
    setState(() => _saving = true);

    try {
      final culture = Culture(
        id: widget.culture?.id,
        nom: _nomController.text.trim(),
        type: _type,
        dateSemis: _dateSemis,
        stade: _stade,
        superficie: double.parse(_superficieController.text.replaceAll(',', '.')),
        parcelle: _parcelleController.text.trim(),
        note: _noteController.text.trim(),
        photoPath: _photoPath,
      );

      final provider = context.read<CultureProvider>();
      if (_isEdition) {
        await provider.updateCulture(culture);
      } else {
        await provider.addCulture(culture);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    } finally {
      // Essentiel : sans ce bloc, une erreur laisse le bouton bloqué en
      // chargement indéfiniment et l'écran semble figé.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdition ? 'Modifier la culture' : 'Nouvelle culture')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.softGreen,
                    shape: BoxShape.circle,
                    image: _photoPath != null
                        ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _photoPath == null
                      ? const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryGreen, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _pickPhoto,
                child: Text(_photoPath == null ? 'Ajouter une photo (optionnel)' : 'Changer la photo'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom de la culture *'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type de culture *'),
              items: Culture.typesCourants
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date de semis *'),
                child: Text('${_dateSemis.day}/${_dateSemis.month}/${_dateSemis.year}'),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _stade,
              decoration: const InputDecoration(labelText: 'Stade actuel *'),
              items: Culture.stades
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _stade = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _superficieController,
              decoration: const InputDecoration(labelText: 'Superficie (ha) *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Valeur invalide';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _parcelleController,
              decoration: const InputDecoration(labelText: 'Parcelle *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note libre (optionnel)'),
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
                  : Text(_isEdition ? 'Enregistrer les modifications' : 'Ajouter la culture'),
            ),
          ],
        ),
      ),
    );
  }
}
