import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette et thème visuel de l'application : identité "agriculture moderne",
/// verts profonds, fond crème, cartes arrondies, typographie douce (Poppins/Inter).
class AppTheme {
  AppTheme._();

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color leafGreen = Color(0xFF43A047);
  static const Color softGreen = Color(0xFFE8F5E9);
  static const Color earthBrown = Color(0xFF8D6E63);
  static const Color sunYellow = Color(0xFFFFB300);
  static const Color background = Color(0xFFF7F8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFD84315);

  static const List<Color> heroGradient = [Color(0xFF1B5E20), Color(0xFF4C9A2A)];

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: leafGreen,
        surface: surface,
        error: danger,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: const Color(0xFF1B1B1B),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1B1B1B),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: softGreen,
        labelStyle: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
        selectedColor: primaryGreen,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softGreen.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.6),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEDEFE7), thickness: 1),
    );
  }

  static BoxDecoration heroCardDecoration() => BoxDecoration(
        gradient: const LinearGradient(
          colors: heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static Color stadeColor(String stade) {
    switch (stade) {
      case 'Semis':
        return const Color(0xFF8D6E63);
      case 'Levée':
        return const Color(0xFF7CB342);
      case 'Croissance':
        return const Color(0xFF43A047);
      case 'Floraison':
        return const Color(0xFFEC407A);
      case 'Maturation':
        return const Color(0xFFFFB300);
      case 'Récolté':
        return const Color(0xFF616161);
      default:
        return primaryGreen;
    }
  }
}
