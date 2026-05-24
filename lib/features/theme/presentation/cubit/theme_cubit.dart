// lib/features/theme/presentation/cubit/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/theme/domain/usecases/get_theme_mode.dart';
import 'package:app_properties/features/theme/domain/usecases/save_theme_mode.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final GetThemeMode _getThemeMode;
  final SaveThemeMode _saveThemeMode;

  ThemeCubit({
    required GetThemeMode getThemeMode,
    required SaveThemeMode saveThemeMode,
  })  : _getThemeMode = getThemeMode,
        _saveThemeMode = saveThemeMode,
        super(ThemeMode.light);

  /// Load persisted preference on startup.
  Future<void> init() async {
    final mode = await _getThemeMode();
    emit(mode);
  }

  bool get isDark => state == ThemeMode.dark;

  Future<void> toggleTheme() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    await _saveThemeMode(next);
    emit(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _saveThemeMode(mode);
    emit(mode);
  }
}
