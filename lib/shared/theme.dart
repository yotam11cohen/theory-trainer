import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static const _primaryColor = Color(0xFF6C63FF);
  static const _bgColor = Color(0xFF0F0F1A);
  static const _surfaceColor = Color(0xFF1A1A2E);
  static const _cardColor = Color(0xFF16213E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primaryColor,
          surface: _bgColor,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: _bgColor,
        cardColor: _cardColor,
        textTheme: GoogleFonts.heeboTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _bgColor,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceColor,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.white54,
        ),
      );
}
