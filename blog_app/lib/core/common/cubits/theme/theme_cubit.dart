import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// key used to persist the chosen theme so it survives a hot restart/app relaunch
const _themeModeKey = 'isDarkMode';

class ThemeCubit extends Cubit<ThemeMode> {
  /// [initialThemeMode] should come from [loadSavedTheme] so the very first
  /// frame already renders in the theme the user last picked.
  ThemeCubit([ThemeMode initialThemeMode = ThemeMode.dark])
      : super(initialThemeMode);

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);
    _saveTheme(newMode);
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, mode == ThemeMode.dark);
  }

  /// Reads the previously saved theme; defaults to dark when nothing is
  /// stored yet (e.g. first launch).
  static Future<ThemeMode> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModeKey) ?? true;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
