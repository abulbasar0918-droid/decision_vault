import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/db_constants.dart';

/// A singleton helper to manage the local SQLite database connection.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppDatabaseConstants.databaseName);

    return openDatabase(
      path,
      version: AppDatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute(AppDatabaseConstants.createTodosTable);
    await database.execute(AppDatabaseConstants.createTodosIndexes);

    await database.execute(AppDatabaseConstants.createTodoDepsTable);
    await database.execute(AppDatabaseConstants.createTodoDepsIndexes);

    await database.execute(AppDatabaseConstants.createDecisionsTable);
    await database.execute(AppDatabaseConstants.createDecisionsIndexes);
  }

  Future<void> _onUpgrade(Database database, int oldVersion, int newVersion) async {
    if (oldVersion >= newVersion) return;

    for (var v = oldVersion + 1; v <= newVersion; v++) {
      final migration = DatabaseMigrationRegistry._migrations[v];
      if (migration != null) {
        await migration(database);
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}

class DatabaseMigrationRegistry {
  DatabaseMigrationRegistry._();

  static final Map<int, Future<void> Function(Database)> _migrations = {
    2: (database) async {
      await database.execute(AppDatabaseConstants.createDecisionsTable);
      await database.execute(AppDatabaseConstants.createDecisionsIndexes);
    },
    3: (database) async {
      // Add is_draft column to decisions table for draft/autosave support
      try {
        await database.execute('ALTER TABLE ${AppDatabaseConstants.decisionsTable} ADD COLUMN ${AppDatabaseConstants.colDecisionIsDraft} INTEGER NOT NULL DEFAULT 0');
      } catch (_) {
        // ignore if column already exists or alter fails on some platforms
      }
      // Create index to support quick draft queries
      try {
        await database.execute('CREATE INDEX IF NOT EXISTS ${AppDatabaseConstants.idxDecisionsIsDraft} ON ${AppDatabaseConstants.decisionsTable}(${AppDatabaseConstants.colDecisionIsDraft})');
      } catch (_) {}
    },
    4: (database) async {
      // Create history table and indexes
      try {
        await database.execute(AppDatabaseConstants.createHistoryTable);
        await database.execute(AppDatabaseConstants.createHistoryIndexes);
      } catch (_) {}

      // Create journal table and indexes
      try {
        await database.execute(AppDatabaseConstants.createJournalTable);
        await database.execute(AppDatabaseConstants.createJournalIndexes);
      } catch (_) {}
    },
  };

  static void register(int targetVersion, Future<void> Function(Database) fn) {
    _migrations[targetVersion] = fn;
  }

  static void clear() {
    _migrations.clear();
  }
}
