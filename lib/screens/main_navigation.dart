import 'package:flutter/material.dart';
import 'advice_screen.dart';
import 'cultures_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// Navigation principale par BottomNavigationBar (Accueil, Cultures, Conseils),
/// avec accès aux Paramètres depuis une icône dans l'AppBar de l'accueil.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    CulturesScreen(),
    AdviceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _screens),
          if (_index == 0)
            Positioned(
              top: 8,
              right: 12,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.grass_rounded), label: 'Cultures'),
          BottomNavigationBarItem(icon: Icon(Icons.tips_and_updates_rounded), label: 'Conseils'),
        ],
      ),
    );
  }
}
