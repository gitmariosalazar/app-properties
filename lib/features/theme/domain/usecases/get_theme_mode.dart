// lib/features/theme/domain/usecases/get_theme_mode.dart
import 'package:flutter/material.dart';
import 'package:app_properties/features/theme/domain/repositories/theme_repository.dart';

class GetThemeMode {
  final ThemeRepository repository;
  GetThemeMode(this.repository);
  Future<ThemeMode> call() => repository.getThemeMode();
}
