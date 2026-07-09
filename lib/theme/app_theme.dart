import 'package:flutter/material.dart';

class AppTheme {
  static const Color _background = Color(0xFF0A0A0A);
  static const Color _surface = Color(0xFF141414);
  static const Color _surfaceContainer = Color(0xFF1E1E1E);
  static const Color _primary = Color(0xFFE0E0E0);
  static const Color _secondary = Color(0xFF9E9E9E);
  static const Color _accent = Color(0xFFFFFFFF);
  static const Color _error = Color(0xFFCF6679);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _primary,
        onPrimary: _background,
        secondary: _secondary,
        onSecondary: _background,
        surface: _surface,
        onSurface: _accent,
        error: _error,
        onError: _background,
        surfaceContainerHighest: _surfaceContainer,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _accent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _accent,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        labelStyle: const TextStyle(color: _secondary),
        prefixIconColor: _secondary,
        suffixIconColor: _secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _accent,
        unselectedItemColor: Color(0xFF5A5A5A),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E1E1E),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceContainer,
        contentTextStyle: const TextStyle(color: _accent),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceContainer,
        selectedColor: _primary,
        labelStyle: const TextStyle(color: _secondary, fontSize: 12),
        side: const BorderSide(color: Color(0xFF2A2A2A)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}
