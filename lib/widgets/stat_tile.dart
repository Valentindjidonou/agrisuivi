import 'package:flutter/material.dart';

/// Petite tuile statistique utilisée dans le tableau de bord de l'accueil.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String valeur;
  final String label;
  final Color color;

  const StatTile({
    super.key,
    required this.icon,
    required this.valeur,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(valeur, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.55))),
        ],
      ),
    );
  }
}
