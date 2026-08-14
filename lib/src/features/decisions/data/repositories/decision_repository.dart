import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../../../../core/repository/base_repository.dart';
import '../models/decision_model.dart';

class DecisionRepository extends BaseRepository {
  DecisionRepository(this.db);

  final Database db;

  @override
  Future<void> init() async {}

  Future<DecisionModel> create(DecisionModel model) async {
    final id = await db.insert(AppDatabaseConstants.decisionsTable, model.toMap());
    return model.copyWith(id: id);
  }

  Future<int> update(DecisionModel model) async {
    if (model.id == null) {
      throw ArgumentError('Model must have id to update');
    }

    return db.update(
      AppDatabaseConstants.decisionsTable,
      model.toMap(),
      where: '${AppDatabaseConstants.colDecisionId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    return db.delete(
      AppDatabaseConstants.decisionsTable,
      where: '${AppDatabaseConstants.colDecisionId} = ?',
      whereArgs: [id],
    );
  }

  Future<DecisionModel?> getById(int id) async {
    final maps = await db.query(
      AppDatabaseConstants.decisionsTable,
      where: '${AppDatabaseConstants.colDecisionId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DecisionModel.fromMap(maps.first);
  }

  Future<List<DecisionModel>> getAll({
    bool includeArchived = true,
    String? searchQuery,
    String? category,
    bool? favoriteOnly,
  }) async {
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (!includeArchived) {
      whereClauses.add('${AppDatabaseConstants.colDecisionIsArchived} = ?');
      whereArgs.add(0);
    }

    if (favoriteOnly == true) {
      whereClauses.add('${AppDatabaseConstants.colDecisionIsFavorite} = ?');
      whereArgs.add(1);
    }

    if (category != null && category.isNotEmpty) {
      whereClauses.add('${AppDatabaseConstants.colDecisionCategory} = ?');
      whereArgs.add(category);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('''(
        ${AppDatabaseConstants.colDecisionTitle} LIKE ? OR
        ${AppDatabaseConstants.colDecisionDescription} LIKE ? OR
        ${AppDatabaseConstants.colDecisionNotes} LIKE ? OR
        ${AppDatabaseConstants.colDecisionCategory} LIKE ?
      )''');
      final query = '%${searchQuery.trim()}%';
      whereArgs.addAll([query, query, query, query]);
    }

    final where = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final maps = await db.query(
      AppDatabaseConstants.decisionsTable,
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: '${AppDatabaseConstants.colDecisionUpdatedAt} DESC',
    );

    return maps.map(DecisionModel.fromMap).toList();
  }

  @override
  Future<void> dispose() async {}
}
