/// Database constants used for initializing and versioning the local SQLite database.
class AppDatabaseConstants {
  AppDatabaseConstants._();

  static const String databaseName = 'decision_vault.db';

  // Increment this when schema changes are applied. Migrations will run
  // from lower to higher versions via DatabaseService.
  // Bumped to 4 to add history and journal support
  static const int databaseVersion = 4;

  // Tables
  static const String todosTable = 'todos';
  static const String todoDepsTable = 'todo_deps';
  static const String decisionsTable = 'decisions';
  static const String historyTable = 'history';
  static const String journalTable = 'journal';
  static const String settingsTable = 'settings';
 
  // Columns for todos
  static const String colTodoId = 'id';
  static const String colTodoTitle = 'title';
  static const String colTodoDescription = 'description';
  static const String colTodoIsDone = 'is_done';
  static const String colTodoCreatedAt = 'created_at';
  static const String colTodoUpdatedAt = 'updated_at';

  // Columns for todo_deps
  static const String colTodoDepId = 'id';
  static const String colTodoDepTodoId = 'todo_id';
  static const String colTodoDepDependsOn = 'depends_on';
  static const String colTodoDepCreatedAt = 'created_at';

  // Columns for decisions
  static const String colDecisionId = 'id';
  static const String colDecisionTitle = 'title';
  static const String colDecisionDescription = 'description';
  static const String colDecisionCategory = 'category';
  static const String colDecisionPriority = 'priority';
  static const String colDecisionWeightedScore = 'weighted_score';
  static const String colDecisionPros = 'pros';
  static const String colDecisionCons = 'cons';
  static const String colDecisionNotes = 'notes';
  static const String colDecisionTags = 'tags';
  static const String colDecisionIsFavorite = 'is_favorite';
  static const String colDecisionIsArchived = 'is_archived';
  static const String colDecisionIsDraft = 'is_draft';
  static const String colDecisionCreatedAt = 'created_at';
  static const String colDecisionUpdatedAt = 'updated_at';

  // Columns for history table
  static const String colHistoryId = 'id';
  static const String colHistoryDecisionId = 'decision_id';
  static const String colHistoryEvent = 'event';
  static const String colHistoryPayload = 'payload';
  static const String colHistoryCreatedAt = 'created_at';

  // Columns for journal table
  static const String colJournalId = 'id';
  static const String colJournalTitle = 'title';
  static const String colJournalBody = 'body';
  static const String colJournalCreatedAt = 'created_at';
  static const String colJournalUpdatedAt = 'updated_at';
 
  // Settings table columns
  static const String colSettingsKey = 'key';
  static const String colSettingsValue = 'value';
  static const String colSettingsCreatedAt = 'created_at';
 
  // SQL create statements (version 1)
  static const String createTodosTable = '''
CREATE TABLE $todosTable (
  $colTodoId INTEGER PRIMARY KEY AUTOINCREMENT,
  $colTodoTitle TEXT NOT NULL,
  $colTodoDescription TEXT,
  $colTodoIsDone INTEGER NOT NULL DEFAULT 0,
  $colTodoCreatedAt INTEGER NOT NULL,
  $colTodoUpdatedAt INTEGER NOT NULL
);
''';

  // Index names (explicit names to avoid interpolation warnings)
  static const String idxTodosIsDone = 'idx_todos_is_done';
  static const String idxTodosCreatedAt = 'idx_todos_created_at';

  static const String createTodosIndexes = '''
-- Index to query unfinished/finished tasks quickly
CREATE INDEX $idxTodosIsDone ON $todosTable($colTodoIsDone);
-- Index for created_at to support sorting and range queries
CREATE INDEX $idxTodosCreatedAt ON $todosTable($colTodoCreatedAt);
''';

  static const String createTodoDepsTable = '''
CREATE TABLE $todoDepsTable (
  $colTodoDepId INTEGER PRIMARY KEY AUTOINCREMENT,
  $colTodoDepTodoId INTEGER NOT NULL,
  $colTodoDepDependsOn INTEGER NOT NULL,
  $colTodoDepCreatedAt INTEGER NOT NULL,
  CONSTRAINT fk_todo FOREIGN KEY ($colTodoDepTodoId) REFERENCES $todosTable($colTodoId) ON DELETE CASCADE,
  CONSTRAINT fk_dep FOREIGN KEY ($colTodoDepDependsOn) REFERENCES $todosTable($colTodoId) ON DELETE CASCADE,
  CONSTRAINT uq_todo_dep UNIQUE ($colTodoDepTodoId, $colTodoDepDependsOn)
);
''';

  // Index names for dependencies table
  static const String idxTodoDepsTodoId = 'idx_todo_deps_todo_id';
  static const String idxTodoDepsDependsOn = 'idx_todo_deps_depends_on';

  static const String createTodoDepsIndexes = '''
CREATE INDEX $idxTodoDepsTodoId ON $todoDepsTable($colTodoDepTodoId);
CREATE INDEX $idxTodoDepsDependsOn ON $todoDepsTable($colTodoDepDependsOn);
''';

  static const String createDecisionsTable = '''
CREATE TABLE $decisionsTable (
  $colDecisionId INTEGER PRIMARY KEY AUTOINCREMENT,
  $colDecisionTitle TEXT NOT NULL,
  $colDecisionDescription TEXT,
  $colDecisionCategory TEXT,
  $colDecisionPriority INTEGER NOT NULL DEFAULT 2,
  $colDecisionWeightedScore INTEGER NOT NULL DEFAULT 0,
  $colDecisionPros TEXT,
  $colDecisionCons TEXT,
  $colDecisionNotes TEXT,
  $colDecisionTags TEXT,
  $colDecisionIsFavorite INTEGER NOT NULL DEFAULT 0,
  $colDecisionIsArchived INTEGER NOT NULL DEFAULT 0,
  $colDecisionIsDraft INTEGER NOT NULL DEFAULT 0,
  $colDecisionCreatedAt INTEGER NOT NULL,
  $colDecisionUpdatedAt INTEGER NOT NULL
);
''';

  static const String idxDecisionsCategory = 'idx_decisions_category';
  static const String idxDecisionsPriority = 'idx_decisions_priority';
  static const String idxDecisionsUpdatedAt = 'idx_decisions_updated_at';
  static const String idxDecisionsIsDraft = 'idx_decisions_is_draft';

  static const String createDecisionsIndexes = '''
CREATE INDEX $idxDecisionsCategory ON $decisionsTable($colDecisionCategory);
CREATE INDEX $idxDecisionsPriority ON $decisionsTable($colDecisionPriority);
CREATE INDEX $idxDecisionsUpdatedAt ON $decisionsTable($colDecisionUpdatedAt);
CREATE INDEX $idxDecisionsIsDraft ON $decisionsTable($colDecisionIsDraft);
''';

  // History table to keep an append-only timeline of decision events
  static const String createHistoryTable = '''
CREATE TABLE $historyTable (
  $colHistoryId INTEGER PRIMARY KEY AUTOINCREMENT,
  $colHistoryDecisionId INTEGER,
  $colHistoryEvent TEXT NOT NULL,
  $colHistoryPayload TEXT,
  $colHistoryCreatedAt INTEGER NOT NULL,
  FOREIGN KEY ($colHistoryDecisionId) REFERENCES $decisionsTable($colDecisionId) ON DELETE SET NULL
);
''';

  static const String idxHistoryDecisionId = 'idx_history_decision_id';
  static const String idxHistoryCreatedAt = 'idx_history_created_at';

  static const String createHistoryIndexes = '''
CREATE INDEX $idxHistoryDecisionId ON $historyTable($colHistoryDecisionId);
CREATE INDEX $idxHistoryCreatedAt ON $historyTable($colHistoryCreatedAt);
''';

  // Simple journal table for user notes
  static const String createJournalTable = '''
CREATE TABLE $journalTable (
  $colJournalId INTEGER PRIMARY KEY AUTOINCREMENT,
  $colJournalTitle TEXT NOT NULL,
  $colJournalBody TEXT,
  $colJournalCreatedAt INTEGER NOT NULL,
  $colJournalUpdatedAt INTEGER NOT NULL
);
''';
 
  static const String idxJournalCreatedAt = 'idx_journal_created_at';
 
  static const String createJournalIndexes = '''
CREATE INDEX $idxJournalCreatedAt ON $journalTable($colJournalCreatedAt);
''';
 
  static const String createSettingsTable = '''
CREATE TABLE $settingsTable (
  $colSettingsKey TEXT PRIMARY KEY,
  $colSettingsValue TEXT NOT NULL,
  $colSettingsCreatedAt INTEGER NOT NULL
);
''';
 
  static const String idxSettingsCreatedAt = 'idx_settings_created_at';
 
  static const String createSettingsIndexes = '''
CREATE INDEX $idxSettingsCreatedAt ON $settingsTable($colSettingsCreatedAt);
''';
}
