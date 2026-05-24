// lib/features/theme/data/repositories/theme_repository_impl.dart
import 'package:flutter/material.dart';
import 'package:app_properties/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:app_properties/features/theme/domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource dataSource;
  ThemeRepositoryImpl({required this.dataSource});

  @override
  Future<ThemeMode> getThemeMode() => dataSource.getThemeMode();

  @override
  Future<void> saveThemeMode(ThemeMode mode) => dataSource.saveThemeMode(mode);
}
