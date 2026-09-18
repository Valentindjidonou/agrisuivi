import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/culture.dart';
import '../theme/app_theme.dart';

/// Carte moderne présentant une culture dans la liste : icône, nom, type,
/// parcelle, superficie et badge de stade coloré.
class CultureCard extends StatelessWidget {
  final Culture culture;
  final VoidCallback onTap;

  const CultureCard({super.key, required this.culture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stadeColor = AppTheme.stadeColor(culture.stade);
    final dateFmt = DateFormat('d MMM yyyy', 'fr_FR');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDEFE7)),
          ),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            culture.nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: stadeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            culture.stade,
                            style: TextStyle(
                              color: stadeColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${culture.type} · Parcelle ${culture.parcelle}',
                      style: TextStyle(color: Colors.black.withValues(alpha: 0.55), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.straighten, size: 14, color: Colors.black.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text('${culture.superficie} ha',
                            style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.55))),
                        const SizedBox(width: 14),
                        Icon(Icons.event, size: 14, color: Colors.black.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(dateFmt.format(culture.dateSemis),
                            style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.55))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.black.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (culture.photoPath != null && File(culture.photoPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(culture.photoPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 28),
    );
  }
}
