import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Affiché quand une liste (cultures, activités, alertes...) est vide.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.titre,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppTheme.softGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 20),
            Text(
              titre,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 13.5, color: Colors.black.withValues(alpha: 0.55), height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
