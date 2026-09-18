import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/culture.dart';
import '../providers/culture_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/culture_card.dart';
import '../widgets/empty_state.dart';
import 'culture_detail_screen.dart';
import 'culture_form_screen.dart';

/// Liste des cultures suivies, avec recherche et filtre par stade.
class CulturesScreen extends StatefulWidget {
  const CulturesScreen({super.key});

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CultureProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CultureProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cultures')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Rechercher une culture, une parcelle…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'Toutes',
                  selected: provider.stadeFilter == null,
                  onTap: () => provider.setStadeFilter(null),
                ),
                const SizedBox(width: 8),
                ...Culture.stades.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: s,
                      selected: provider.stadeFilter == s,
                      onTap: () => provider.setStadeFilter(s),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.cultures.isEmpty
                    ? EmptyState(
                        icon: Icons.grass_rounded,
                        titre: 'Aucune culture pour le moment',
                        message: 'Ajoutez votre première culture pour commencer le suivi de vos parcelles.',
                        action: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CultureFormScreen()),
                            );
                            if (mounted) await context.read<CultureProvider>().load();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une culture'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: provider.cultures.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final culture = provider.cultures[index];
                          return CultureCard(
                            culture: culture,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CultureDetailScreen(cultureId: culture.id!),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CultureFormScreen()),
          );
          if (mounted) await context.read<CultureProvider>().load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : AppTheme.softGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
