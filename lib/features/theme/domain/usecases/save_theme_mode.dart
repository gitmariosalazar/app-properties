// lib/features/theme/domain/usecases/save_theme_mode.dart
import 'package:flutter/material.dart';
import 'package:app_properties/features/theme/domain/repositories/theme_repository.dart';

class SaveThemeMode {
  final ThemeRepository repository;
  SaveThemeMode(this.repository);
  Future<void> call(ThemeMode mode) => repository.saveThemeMode(mode);
}
