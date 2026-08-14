import 'package:flutter/material.dart';

import '../../../../core/database/database_service.dart';
import '../../data/repositories/settings_repository.dart';

/// Provider for application-wide settings, including theme selection and backup operations.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _initialize();
  }

  static const String themeModeKey = 'theme_mode';

  final DatabaseService _databaseService = DatabaseService.instance;
  SettingsRepository? _repository;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String get themeModeLabel {
    switch (_themeMode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> _initialize() async {
    try {
      await _databaseService.init();
      _repository ??= SettingsRepository(await _databaseService.database);
      await _repository!.init();
      final stored = await _repository!.getValue(themeModeKey);
      if (stored != null) {
        _themeMode = _parseThemeMode(stored);
      }
      notifyListeners();
    } catch (_) {
      // Ignore initialization failures for settings; defaults remain available.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      _repository ??= SettingsRepository(await _databaseService.database);
      await _repository!.setValue(themeModeKey, _themeMode.name);
    } catch (_) {
      // Swallow persistence failures but keep the selected theme.
    }
  }

  ThemeMode _parseThemeMode(String raw) {
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> reloadTheme() async {
    await _initialize();
  }
}
