import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';

/// Repository responsible for storing and reading application settings.
class SettingsRepository {
  SettingsRepository(this.db);

  final Database db;

  Future<void> init() async {}

  Future<String?> getValue(String key) async {
    final maps = await db.query(
      AppDatabaseConstants.settingsTable,
      columns: [AppDatabaseConstants.colSettingsValue],
      where: '${AppDatabaseConstants.colSettingsKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }

    return maps.first[AppDatabaseConstants.colSettingsValue] as String?;
  }

  Future<void> setValue(String key, String value) async {
    await db.insert(
      AppDatabaseConstants.settingsTable,
      {
        AppDatabaseConstants.colSettingsKey: key,
        AppDatabaseConstants.colSettingsValue: value,
        AppDatabaseConstants.colSettingsCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> dispose() async {}
}
