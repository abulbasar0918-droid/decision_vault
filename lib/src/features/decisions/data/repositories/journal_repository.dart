import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/db_constants.dart';
import '../models/journal_model.dart';

class JournalRepository {
  JournalRepository(this.db);

  final Database db;

  Future<void> init() async {}

  Future<JournalModel> create(JournalModel model) async {
    final id = await db.insert(AppDatabaseConstants.journalTable, model.toMap());
    return model.copyWith(id: id);
  }

  Future<int> update(JournalModel model) async {
    if (model.id == null) throw ArgumentError('Model must have id to update');
    return db.update(
      AppDatabaseConstants.journalTable,
      model.toMap(),
      where: '${AppDatabaseConstants.colJournalId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    return db.delete(
      AppDatabaseConstants.journalTable,
      where: '${AppDatabaseConstants.colJournalId} = ?',
      whereArgs: [id],
    );
  }

  Future<JournalModel?> getById(int id) async {
    final maps = await db.query(
      AppDatabaseConstants.journalTable,
      where: '${AppDatabaseConstants.colJournalId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return JournalModel.fromMap(maps.first);
  }

  Future<List<JournalModel>> getAll({int limit = 200}) async {
    final maps = await db.query(
      AppDatabaseConstants.journalTable,
      orderBy: '${AppDatabaseConstants.colJournalCreatedAt} DESC',
      limit: limit,
    );
    return maps.map(JournalModel.fromMap).toList();
  }

  Future<void> dispose() async {}
}
