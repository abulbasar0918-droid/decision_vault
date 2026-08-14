import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/repository/base_repository.dart';
import '../models/todo_dep_model.dart';

class TodoDepRepository extends BaseRepository {
  final Database db;

  TodoDepRepository(this.db);

  @override
  Future<void> init() async {}

  Future<TodoDepModel> addDependency(TodoDepModel model) async {
    final id = await db.insert(AppDatabaseConstants.todoDepsTable, model.toMap());
    return model.copyWith(id: id);
  }

  Future<int> removeDependency(int id) async {
    return db.delete(
      AppDatabaseConstants.todoDepsTable,
      where: '${AppDatabaseConstants.colTodoDepId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeDependencyByPair(int todoId, int dependsOn) async {
    return db.delete(
      AppDatabaseConstants.todoDepsTable,
      where: '${AppDatabaseConstants.colTodoDepTodoId} = ? AND ${AppDatabaseConstants.colTodoDepDependsOn} = ?',
      whereArgs: [todoId, dependsOn],
    );
  }

  Future<List<TodoDepModel>> getDependenciesForTodo(int todoId) async {
    final maps = await db.query(
      AppDatabaseConstants.todoDepsTable,
      where: '${AppDatabaseConstants.colTodoDepTodoId} = ?',
      whereArgs: [todoId],
      orderBy: '${AppDatabaseConstants.colTodoDepCreatedAt} ASC',
    );
    return maps.map((m) => TodoDepModel.fromMap(m)).toList();
  }

  Future<List<TodoDepModel>> getDependentsForTodo(int dependsOnId) async {
    final maps = await db.query(
      AppDatabaseConstants.todoDepsTable,
      where: '${AppDatabaseConstants.colTodoDepDependsOn} = ?',
      whereArgs: [dependsOnId],
      orderBy: '${AppDatabaseConstants.colTodoDepCreatedAt} ASC',
    );
    return maps.map((m) => TodoDepModel.fromMap(m)).toList();
  }

  @override
  Future<void> dispose() async {}
}
