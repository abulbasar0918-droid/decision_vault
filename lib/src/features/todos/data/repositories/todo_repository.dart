import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/repository/base_repository.dart';
import '../models/todo_model.dart';

class TodoRepository extends BaseRepository {
  final Database db;

  TodoRepository(this.db);

  @override
  Future<void> init() async {
    // Nothing to init for now, but repository-ready hook.
  }

  Future<TodoModel> create(TodoModel model) async {
    final id = await db.insert(AppDatabaseConstants.todosTable, model.toMap());
    return model.copyWith(id: id);
  }

  Future<int> update(TodoModel model) async {
    if (model.id == null) throw ArgumentError('Model must have id to update');
    return db.update(
      AppDatabaseConstants.todosTable,
      model.toMap(),
      where: '${AppDatabaseConstants.colTodoId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    return db.delete(
      AppDatabaseConstants.todosTable,
      where: '${AppDatabaseConstants.colTodoId} = ?',
      whereArgs: [id],
    );
  }

  Future<TodoModel?> getById(int id) async {
    final maps = await db.query(
      AppDatabaseConstants.todosTable,
      where: '${AppDatabaseConstants.colTodoId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TodoModel.fromMap(maps.first);
  }

  Future<List<TodoModel>> getAll({bool? isDone}) async {
    String? where;
    List<dynamic>? whereArgs;
    if (isDone != null) {
      where = '${AppDatabaseConstants.colTodoIsDone} = ?';
      whereArgs = [isDone ? 1 : 0];
    }

    final maps = await db.query(
      AppDatabaseConstants.todosTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${AppDatabaseConstants.colTodoCreatedAt} DESC',
    );

    return maps.map((m) => TodoModel.fromMap(m)).toList();
  }

  @override
  Future<void> dispose() async {
    // nothing to dispose; database is closed by DatabaseService
  }
}
