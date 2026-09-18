import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/alerte.dart';
import '../providers/advice_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/culture_provider.dart';
import '../theme/app_theme.dart';
import '../utils/seasons.dart';
import '../widgets/advice_card.dart';
import '../widgets/stat_tile.dart';
import 'culture_detail_screen.dart';
import 'culture_form_screen.dart';

/// Écran d'accueil : tableau de bord synthétique avec statistiques,
/// bannière de saison et prochaines alertes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CultureProvider>().load();
      context.read<AlertProvider>().loadUpcoming();
      context.read<AdviceProvider>().load();
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final cultureProvider = context.watch<CultureProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final adviceProvider = context.watch<AdviceProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<CultureProvider>().load();
            await context.read<AlertProvider>().loadUpcoming();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Text(
                '${_greeting()} 👋',
                style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 2),
              const Text(
                'AgriSuivi',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _buildSeasonBanner(context, adviceProvider),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.eco_rounded,
                      valeur: '${cultureProvider.culturesActives}',
                      label: 'Cultures actives',
                      color: AppTheme.leafGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Icons.notifications_active_rounded,
                      valeur: '${alertProvider.prochaines.length}',
                      label: 'Alertes à venir',
                      color: AppTheme.sunYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionHeader('Prochaines alertes'),
              const SizedBox(height: 12),
              if (alertProvider.prochaines.isEmpty)
                _buildEmptyAlerts()
              else
                ...alertProvider.prochaines.take(4).map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AlertRow(alerte: a),
                      ),
                    ),
              const SizedBox(height: 24),
              _sectionHeader('Conseils du moment'),
              const SizedBox(height: 12),
              if (adviceProvider.conseilsDuJour.isEmpty)
                Text('Aucun conseil pour le moment.',
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.5)))
              else
                ...adviceProvider.conseilsDuJour.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AdviceCard(conseil: c),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CultureFormScreen()),
          );
          if (mounted) {
            await context.read<CultureProvider>().load();
            await context.read<AlertProvider>().loadUpcoming();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle culture'),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  }

  Widget _buildEmptyAlerts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFE7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTheme.leafGreen),
          const SizedBox(width: 12),
          const Expanded(child: Text('Aucune alerte en attente pour le moment.')),
        ],
      ),
    );
  }

  Widget _buildSeasonBanner(BuildContext context, AdviceProvider adviceProvider) {
    final saison = Seasons.current();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.heroCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(Seasons.emoji(saison), style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                'Nous sommes en $saison',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Consultez les conseils adaptés à la saison pour bien accompagner vos cultures.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final Alerte alerte;
  const _AlertRow({required this.alerte});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM · HH:mm', 'fr_FR');
    final enRetard = alerte.estEnRetard;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final culture = await context.read<CultureProvider>().getById(alerte.cultureId);
        if (culture != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CultureDetailScreen(cultureId: culture.id!)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDEFE7)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (enRetard ? AppTheme.danger : AppTheme.sunYellow).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                enRetard ? Icons.warning_rounded : Icons.notifications_rounded,
                color: enRetard ? AppTheme.danger : AppTheme.sunYellow,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alerte.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    dateFmt.format(alerte.dateEcheance),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: enRetard ? AppTheme.danger : Colors.black.withValues(alpha: 0.5),
                      fontWeight: enRetard ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.black.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
