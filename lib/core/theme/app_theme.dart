import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _brand = Color(0xFF294B45);
  static const Color _lightBackground = Color(0xFFF5F7F2);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFDCE3D8);

  static ThemeData get lightTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _brand,
          brightness: Brightness.light,
        ).copyWith(
          primary: _brand,
          onPrimary: Colors.white,
          surface: _lightBackground,
          onSurface: const Color(0xFF172B2A),
          surfaceContainer: const Color(0xFFE8EDE3),
          surfaceContainerLow: _lightCard,
          outlineVariant: _lightBorder,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      dividerColor: scheme.outlineVariant,
    );
  }

  static ThemeData get darkTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8AEFF),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFC5BCFF),
          onPrimary: const Color(0xFF241B55),
          primaryContainer: const Color(0xFF454078),
          onPrimaryContainer: const Color(0xFFE7E2FF),
          secondary: const Color(0xFFB0D4C7),
          onSecondary: const Color(0xFF19372F),
          surface: const Color(0xFF141318),
          onSurface: const Color(0xFFE8E1EC),
          surfaceContainerLowest: const Color(0xFF0F0E13),
          surfaceContainerLow: const Color(0xFF1D1B22),
          surfaceContainer: const Color(0xFF242129),
          surfaceContainerHigh: const Color(0xFF302D36),
          surfaceContainerHighest: const Color(0xFF3B3742),
          onSurfaceVariant: const Color(0xFFCAC4D0),
          outline: const Color(0xFF918B99),
          outlineVariant: const Color(0xFF48434F),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
