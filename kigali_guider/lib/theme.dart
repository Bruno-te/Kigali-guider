import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching the dark navy UI design
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryNavy = Color(0xFF1A2D42);
  static const Color cardDark = Color(0xFF1E3148);
  static const Color accent = Color(0xFFF5A623);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputText = Color(0xFF0D1B2A);
  static const Color tagBackground = Color(0xFF2A3F55);
  static const Color tagBorder = Color(0xFF3A5068);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: primaryNavy,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentGold,
        surface: primaryNavy,
        background: primaryDark,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryNavy,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tagBackground,
        selectedColor: accent,
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        side: const BorderSide(color: tagBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textMuted),
      ),
    );
  }
}

class AppCategories {
  static const List<String> all = [
    'All',
    'Café',
    'Restaurant',
    'Hospital',
    'Pharmacy',
    'Police Station',
    'Library',
    'Park',
    'Tourist Attraction',
    'Utility Office',
    'Hotel',
    'School',
    'Bank',
    'Gym',
  ];

  static const Map<String, IconData> icons = {
    'All': Icons.grid_view_rounded,
    'Café': Icons.coffee,
    'Restaurant': Icons.restaurant,
    'Hospital': Icons.local_hospital,
    'Pharmacy': Icons.local_pharmacy,
    'Police Station': Icons.local_police,
    'Library': Icons.local_library,
    'Park': Icons.park,
    'Tourist Attraction': Icons.attractions,
    'Utility Office': Icons.business,
    'Hotel': Icons.hotel,
    'School': Icons.school,
    'Bank': Icons.account_balance,
    'Gym': Icons.fitness_center,
  };

  static IconData getIcon(String category) {
    return icons[category] ?? Icons.place;
  }
}
