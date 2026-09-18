import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activite.dart';
import '../models/alerte.dart';
import '../models/culture.dart';
import '../providers/activity_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/culture_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'activity_form_screen.dart';
import 'alert_form_screen.dart';
import 'culture_form_screen.dart';

/// Détail d'une culture : informations, onglet Activités et onglet Alertes.
class CultureDetailScreen extends StatefulWidget {
  final int cultureId;
  const CultureDetailScreen({super.key, required this.cultureId});

  @override
  State<CultureDetailScreen> createState() => _CultureDetailScreenState();
}

class _CultureDetailScreenState extends State<CultureDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Culture? _culture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCulture();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadForCulture(widget.cultureId);
      context.read<AlertProvider>().loadForCulture(widget.cultureId);
    });
  }

  Future<void> _loadCulture() async {
    final c = await context.read<CultureProvider>().getById(widget.cultureId);
    if (mounted) setState(() => _culture = c);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la culture ?'),
        content: const Text('Cette action supprimera aussi ses activités et alertes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<CultureProvider>().deleteCulture(widget.cultureId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final culture = _culture;
    if (culture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dateFmt = DateFormat('d MMMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Text(culture.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CultureFormScreen(culture: culture)),
              );
              _loadCulture();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDEFE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.stadeColor(culture.stade).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        culture.stade,
                        style: TextStyle(
                          color: AppTheme.stadeColor(culture.stade),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('${culture.superficie} ha',
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.55))),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.category_outlined, 'Type', culture.type),
                _infoRow(Icons.map_outlined, 'Parcelle', culture.parcelle),
                _infoRow(Icons.event_outlined, 'Date de semis', dateFmt.format(culture.dateSemis)),
                if (culture.note.isNotEmpty) _infoRow(Icons.notes_rounded, 'Note', culture.note),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.black45,
            indicatorColor: AppTheme.primaryGreen,
            tabs: const [
              Tab(text: 'Activités'),
              Tab(text: 'Alertes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ActivitiesTab(cultureId: culture.id!),
                _AlertsTab(culture: culture),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.black.withValues(alpha: 0.45)),
          const SizedBox(width: 10),
          Text('$label : ', style: TextStyle(color: Colors.black.withValues(alpha: 0.55), fontSize: 13.5)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
        ],
      ),
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  final int cultureId;
  const _ActivitiesTab({required this.cultureId});

  IconData _iconFor(String type) {
    switch (type) {
      case 'Arrosage':
        return Icons.water_drop_rounded;
      case 'Traitement':
        return Icons.science_rounded;
      case 'Désherbage':
        return Icons.grass_rounded;
      case 'Récolte':
        return Icons.agriculture_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<ActivityProvider>().forCulture(cultureId);
    final dateFmt = DateFormat('d MMM yyyy', 'fr_FR');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: activities.isEmpty
          ? EmptyState(
              icon: Icons.book_outlined,
              titre: 'Aucune activité enregistrée',
              message: 'Ajoutez un arrosage, un traitement, un désherbage ou une récolte.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = activities[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDEFE7)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_iconFor(a.type), color: AppTheme.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.type, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(dateFmt.format(a.date),
                                style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.5))),
                            if (a.remarque.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(a.remarque, style: const TextStyle(fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.black38),
                        onPressed: () => context.read<ActivityProvider>().deleteActivite(a.id!, cultureId),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'add_activity',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityFormScreen(cultureId: cultureId)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  final Culture culture;
  const _AlertsTab({required this.culture});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertProvider>().forCulture(culture.id!);
    final dateFmt = DateFormat('d MMM yyyy · HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: alerts.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              titre: 'Aucune alerte programmée',
              message: 'Programmez un rappel pour ne manquer aucune étape importante.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = alerts[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDEFE7)),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: a.estFaite,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (_) => context.read<AlertProvider>().toggleFaite(a),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.titre,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: a.estFaite ? TextDecoration.lineThrough : null,
                                color: a.estFaite ? Colors.black38 : Colors.black87,
                              ),
                            ),
                            Text(
                              dateFmt.format(a.dateEcheance),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: a.estEnRetard ? AppTheme.danger : Colors.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.black38),
                        onPressed: () => context.read<AlertProvider>().deleteAlerte(a),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'add_alert',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlertFormScreen(culture: culture)),
        ),
        child: const Icon(Icons.add_alert_rounded),
      ),
    );
  }
}
