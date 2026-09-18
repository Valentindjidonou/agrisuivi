import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advice_provider.dart';
import '../theme/app_theme.dart';
import '../utils/seasons.dart';
import '../widgets/advice_card.dart';
import '../widgets/empty_state.dart';

/// Liste des conseils saisonniers, filtrables par saison via des onglets/chips.
class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdviceProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Conseils saisonniers')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: Seasons.toutes.map((s) {
                      final selected = provider.saisonSelectionnee == s;
                      final isCurrent = s == provider.saisonActuelle;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => provider.setSaison(s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primaryGreen : AppTheme.softGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(Seasons.emoji(s), style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  s,
                                  style: TextStyle(
                                    color: selected ? Colors.white : AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.circle,
                                      size: 6, color: selected ? Colors.white : AppTheme.sunYellow),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: provider.conseilsFiltres.isEmpty
                      ? const EmptyState(
                          icon: Icons.tips_and_updates_outlined,
                          titre: 'Aucun conseil disponible',
                          message: 'Aucun conseil n\'est enregistré pour cette saison.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: provider.conseilsFiltres.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              AdviceCard(conseil: provider.conseilsFiltres[index]),
                        ),
                ),
              ],
            ),
    );
  }
}
