// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single source of truth for the app's visual style.
/// OCP: add new color roles here without modifying consuming widgets.
class AppTheme {
  AppTheme._();

  // ── Brand colors ──────────────────────────────────────────────────────────
  static const _primaryBlue = Color(0xFF1565C0);
  static const _primaryNavy = Color(0xFF0A1628);
  static const _accentCyan = Color(0xFF00BFFF);
  static const _accentEmerald = Color(0xFF1EB980);
  static const _accentAmber = Color(0xFFFFC107);
  static const _errorRed = Color(0xFFC62828);

  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD6E4FF),
      onPrimaryContainer: _primaryNavy,
      secondary: _accentEmerald,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD4F5E5),
      onSecondaryContainer: Color(0xFF003824),
      tertiary: _accentAmber,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFFFFF3CD),
      onTertiaryContainer: Color(0xFF3D2900),
      error: _errorRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF5F7FA),
      onSurface: Color(0xFF1A2035),
      surfaceContainerHighest: Color(0xFFE8EDF2),
      onSurfaceVariant: Color(0xFF607D8B),
      outline: Color(0xFFBDC9D4),
      outlineVariant: Color(0xFFDDE3E9),
      inverseSurface: Color(0xFF2D3748),
      onInverseSurface: Color(0xFFF0F4F8),
      inversePrimary: _accentCyan,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: cs.surface,
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8EDF2)),
        ),
        margin: EdgeInsets.zero,
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: const BorderSide(color: _primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorRed),
        ),
        hintStyle: const TextStyle(color: Color(0xFF8899AA)),
      ),
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFECF2FF),
        selectedColor: _primaryBlue,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EDF2),
        thickness: 1,
        space: 1,
      ),
      // List tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _primaryBlue
              : Colors.grey.shade300,
        ),
      ),
      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryBlue,
        linearTrackColor: Color(0xFFE0E8F0),
      ),
      // Text
      textTheme: _lightTextTheme,
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    const bgDeep = Color(0xFF060D19);
    const bgCard = Color(0xFF0D1B2E);
    const bgSurface = Color(0xFF112035);
    const onBg = Color(0xFFE8F0FA);
    const onCard = Color(0xFFC8D8EE);
    const border = Color(0xFF1E3350);

    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: _accentCyan,
      onPrimary: _primaryNavy,
      primaryContainer: Color(0xFF003A5C),
      onPrimaryContainer: _accentCyan,
      secondary: _accentEmerald,
      onSecondary: Color(0xFF003824),
      secondaryContainer: Color(0xFF00522E),
      onSecondaryContainer: Color(0xFFACF2CA),
      tertiary: _accentAmber,
      onTertiary: Color(0xFF3D2900),
      tertiaryContainer: Color(0xFF573D00),
      onTertiaryContainer: Color(0xFFFFE082),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: bgDeep,
      onSurface: onBg,
      surfaceContainerHighest: bgSurface,
      onSurfaceVariant: Color(0xFF8BA4BE),
      outline: border,
      outlineVariant: Color(0xFF1A2F48),
      inverseSurface: onBg,
      onInverseSurface: bgDeep,
      inversePrimary: _primaryBlue,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: bgDeep,
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        foregroundColor: onBg,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onBg,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      // Cards
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentCyan,
          foregroundColor: _primaryNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentCyan,
          side: const BorderSide(color: _accentCyan),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentCyan,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        hintStyle: const TextStyle(color: Color(0xFF5A7FA0)),
      ),
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: bgSurface,
        selectedColor: _accentCyan,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onCard,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      // List tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _primaryNavy
              : Colors.grey.shade600,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _accentCyan
              : const Color(0xFF2A3F5F),
        ),
      ),
      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accentCyan,
        linearTrackColor: Color(0xFF1E3350),
      ),
      // Text
      textTheme: _darkTextTheme,
    );
  }

  // ── Text themes ───────────────────────────────────────────────────────────
  static const _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFF0A1628),
      fontWeight: FontWeight.w800,
    ),
    displayMedium: TextStyle(
      color: Color(0xFF0A1628),
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      color: Color(0xFF0A1628),
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: Color(0xFF0A1628),
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      color: Color(0xFF1A2035),
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color(0xFF1A2035),
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF1A2035),
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF607D8B),
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(color: Color(0xFF2D3748)),
    bodyMedium: TextStyle(color: Color(0xFF4A5568)),
    bodySmall: TextStyle(color: Color(0xFF607D8B)),
    labelLarge: TextStyle(
      color: Color(0xFF1565C0),
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(color: Color(0xFF607D8B)),
  );

  static const _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFFE8F0FA),
      fontWeight: FontWeight.w800,
    ),
    displayMedium: TextStyle(
      color: Color(0xFFE8F0FA),
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      color: Color(0xFFE8F0FA),
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: Color(0xFFE8F0FA),
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      color: Color(0xFFD0E0F0),
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color(0xFFD0E0F0),
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Color(0xFFB8CCE0),
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF8BA4BE),
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(color: Color(0xFFC8D8EE)),
    bodyMedium: TextStyle(color: Color(0xFFABBECF)),
    bodySmall: TextStyle(color: Color(0xFF8BA4BE)),
    labelLarge: TextStyle(
      color: Color(0xFF00BFFF),
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(color: Color(0xFF8BA4BE)),
  );
}
