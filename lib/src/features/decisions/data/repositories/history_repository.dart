import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../models/history_model.dart';

class HistoryRepository {
  HistoryRepository(this.db);

  final Database db;

  Future<void> init() async {}

  Future<HistoryModel> create(HistoryModel model) async {
    final id = await db.insert(AppDatabaseConstants.historyTable, model.toMap());
    return HistoryModel(
      id: id,
      decisionId: model.decisionId,
      event: model.event,
      payload: model.payload,
      createdAt: model.createdAt,
    );
  }

  Future<List<HistoryModel>> getByDecisionId(int decisionId, {int limit = 100}) async {
    final maps = await db.query(
      AppDatabaseConstants.historyTable,
      where: '${AppDatabaseConstants.colHistoryDecisionId} = ?',
      whereArgs: [decisionId],
      orderBy: '${AppDatabaseConstants.colHistoryCreatedAt} DESC',
      limit: limit,
    );
    return maps.map(HistoryModel.fromMap).toList();
  }

  Future<List<HistoryModel>> getAll({int limit = 200, String? searchQuery}) async {
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(${AppDatabaseConstants.colHistoryEvent} LIKE ? OR ${AppDatabaseConstants.colHistoryPayload} LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      whereArgs.addAll([q, q]);
    }

    final where = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final maps = await db.query(
      AppDatabaseConstants.historyTable,
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: '${AppDatabaseConstants.colHistoryCreatedAt} DESC',
      limit: limit,
    );

    return maps.map(HistoryModel.fromMap).toList();
  }

  Future<void> dispose() async {}
}
