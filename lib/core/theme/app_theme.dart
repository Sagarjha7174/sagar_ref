import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1565C0),
    brightness: Brightness.light,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        textTheme: GoogleFonts.poppinsTextTheme(),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: _colorScheme.surface,
          foregroundColor: _colorScheme.onSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _colorScheme.primary,
          unselectedItemColor: _colorScheme.onSurfaceVariant,
          showUnselectedLabels: true,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _colorScheme.primaryContainer,
          foregroundColor: _colorScheme.onPrimaryContainer,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  // Status colors
  static const Color pendingColor = Color(0xFFF9A825);
  static const Color completedColor = Color(0xFF2E7D32);
  static const Color rejectedColor = Color(0xFFC62828);

  // Appliance colors (for charts)
  static const Color acColor = Color(0xFF1565C0);
  static const Color fridgeColor = Color(0xFF2E7D32);
  static const Color washingMachineColor = Color(0xFFF9A825);
}
