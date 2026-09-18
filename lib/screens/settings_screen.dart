import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Écran de paramètres : à propos de l'application, rappel du fonctionnement
/// hors-ligne et limites du projet.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.heroCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: Colors.white, size: 26),
                    SizedBox(width: 10),
                    Text('AgriSuivi',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Suivi des cultures, conseils saisonniers et rappels pour petits exploitants agricoles.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Fonctionnement'),
          _settingsCard([
            _infoTile(Icons.wifi_off_rounded, 'Fonctionne hors-ligne',
                'Toutes vos données restent stockées localement sur votre téléphone.'),
            _infoTile(Icons.lock_outline_rounded, 'Sécurité minimale',
                'Aucune donnée n\'est envoyée vers l\'extérieur.'),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('Limites de cette version'),
          _settingsCard([
            _infoTile(Icons.person_outline_rounded, 'Un seul utilisateur',
                'Pas de compte ni de synchronisation multi-appareils.'),
            _infoTile(Icons.map_outlined, 'Pas de carte',
                'La localisation des parcelles se fait par simple étiquette texte.'),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('À propos'),
          _settingsCard([
            _infoTile(Icons.info_outline_rounded, 'Version', '1.0.0'),
            _infoTile(Icons.storage_outlined, 'Stockage', 'Local (sqflite)'),
            _infoTile(Icons.code_rounded, 'Technologies', 'Flutter · Dart · Provider'),
          ]),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFE7)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.softGreen, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.5)),
    );
  }
}
