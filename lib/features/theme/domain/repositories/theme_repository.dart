// lib/features/theme/domain/repositories/theme_repository.dart
import 'package:flutter/material.dart';

/// SRP: only responsible for persisting & reading the theme preference.
/// OCP: new theme modes (e.g., system) can be added without breaking callers.
abstract class ThemeRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
