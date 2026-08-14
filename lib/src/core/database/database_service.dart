import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import '../../features/todos/data/repositories/todo_repository.dart';
import '../../features/todos/data/repositories/todo_dep_repository.dart';

/// DatabaseService provides a higher-level API for initializing the database
/// and obtaining feature repositories. It wraps DatabaseHelper and ensures
/// migrations can be registered.
class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;
  bool _initialized = false;

  // Repositories (lazy initialized)
  TodoRepository? _todoRepository;
  TodoDepRepository? _todoDepRepository;

  Future<Database> get database async {
    if (_db == null) {
      await init();
    }
    return _db!;
  }

  /// Initialize the database and all dependent repositories.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    _db = await DatabaseHelper.instance.database;

    _todoRepository ??= TodoRepository(_db!);
    _todoDepRepository ??= TodoDepRepository(_db!);

    await _todoRepository!.init();
    await _todoDepRepository!.init();

    _initialized = true;
  }

  TodoRepository get todoRepository {
    if (_todoRepository == null) throw StateError('DatabaseService not initialized');
    return _todoRepository!;
  }

  TodoDepRepository get todoDepRepository {
    if (_todoDepRepository == null) throw StateError('DatabaseService not initialized');
    return _todoDepRepository!;
  }

  Future<void> close() async {
    await _todoRepository?.dispose();
    await _todoDepRepository?.dispose();
    await DatabaseHelper.instance.close();
    _db = null;
    _initialized = false;
  }
}
