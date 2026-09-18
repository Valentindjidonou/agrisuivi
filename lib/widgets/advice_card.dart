import 'package:flutter/material.dart';
import '../models/conseil_saisonnier.dart';
import '../theme/app_theme.dart';
import '../utils/seasons.dart';

/// Carte affichant un conseil saisonnier, avec l'emoji de saison et le type de culture visé.
class AdviceCard extends StatelessWidget {
  final ConseilSaisonnier conseil;

  const AdviceCard({super.key, required this.conseil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(Seasons.emoji(conseil.saison), style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conseil.titre,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        conseil.typeCulture,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  conseil.texte,
                  style: TextStyle(fontSize: 13.5, color: Colors.black.withValues(alpha: 0.65), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
