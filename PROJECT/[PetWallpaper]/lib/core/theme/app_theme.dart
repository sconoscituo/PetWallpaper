import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6B9D);
  static const Color secondary = Color(0xFFFFB347);
  static const Color bgLight = Color(0xFFFFF8F0);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF888888);
  static const Color accent = Color(0xFF6C63FF);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: bgCard,
          background: bgLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onBackground: textPrimary,
        ),
        scaffoldBackgroundColor: bgLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: bgLight,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: bgCard,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bgCard,
          indicatorColor: primary.withOpacity(0.15),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: primary);
            }
            return const IconThemeData(color: textSecondary);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: textSecondary, fontSize: 12);
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        ),
      );
}
