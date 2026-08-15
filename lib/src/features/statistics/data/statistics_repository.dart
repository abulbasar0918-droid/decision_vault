import 'package:sqflite/sqflite.dart';
import 'package:decision_vault/src/core/constants/db_constants.dart';

class StatisticsRepository {
  StatisticsRepository(this.db);

  final Database db;

  Future<int> totalDecisions() async {
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM ${AppDatabaseConstants.decisionsTable}');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> activeDecisions() async {
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM ${AppDatabaseConstants.decisionsTable} WHERE ${AppDatabaseConstants.colDecisionIsArchived} = 0');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> archivedDecisions() async {
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM ${AppDatabaseConstants.decisionsTable} WHERE ${AppDatabaseConstants.colDecisionIsArchived} = 1');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> favoriteDecisions() async {
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM ${AppDatabaseConstants.decisionsTable} WHERE ${AppDatabaseConstants.colDecisionIsFavorite} = 1');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<Map<String,int>> decisionsByCategory() async {
    final rows = await db.rawQuery('SELECT ${AppDatabaseConstants.colDecisionCategory} as category, COUNT(*) as c FROM ${AppDatabaseConstants.decisionsTable} GROUP BY ${AppDatabaseConstants.colDecisionCategory}');
    final map = <String,int>{};
    for (final r in rows) {
      final key = (r['category'] as String?) ?? '';
      map[key] = (r['c'] as int?) ?? 0;
    }
    return map;
  }

  Future<Map<String,int>> decisionsByTag() async {
    final rows = await db.query(AppDatabaseConstants.decisionsTable, columns: [AppDatabaseConstants.colDecisionTags]);
    final counts = <String,int>{};
    for (final r in rows) {
      final raw = r[AppDatabaseConstants.colDecisionTags] as String?;
      if (raw == null || raw.trim().isEmpty) continue;
      final parts = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      for (final p in parts) {
        counts[p] = (counts[p] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<Map<int,int>> priorityDistribution() async {
    final rows = await db.rawQuery('SELECT ${AppDatabaseConstants.colDecisionPriority} as p, COUNT(*) as c FROM ${AppDatabaseConstants.decisionsTable} GROUP BY ${AppDatabaseConstants.colDecisionPriority}');
    final map = <int,int>{};
    for (final r in rows) {
      final p = r['p'] is int ? r['p'] as int : (r['p'] as num?)?.toInt() ?? 0;
      map[p] = (r['c'] as int?) ?? 0;
    }
    return map;
  }

  Future<double> averageWeightedScore() async {
    final rows = await db.rawQuery('SELECT AVG(${AppDatabaseConstants.colDecisionWeightedScore}) as avg FROM ${AppDatabaseConstants.decisionsTable}');
    final val = rows.first['avg'];
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  Future<Map<String,num>> weightedScoreSummary() async {
    final rows = await db.rawQuery('SELECT SUM(${AppDatabaseConstants.colDecisionWeightedScore}) as sum, AVG(${AppDatabaseConstants.colDecisionWeightedScore}) as avg FROM ${AppDatabaseConstants.decisionsTable}');
    final sum = rows.first['sum'];
    final avg = rows.first['avg'];
    final s = sum is num ? sum.toDouble() : double.tryParse(sum?.toString() ?? '') ?? 0.0;
    final a = avg is num ? avg.toDouble() : double.tryParse(avg?.toString() ?? '') ?? 0.0;
    return {'sum': s, 'avg': a};
  }

  /// Recent activity: counts of decisions created per day (YYYY-MM-DD) for the last [days] days.
  Future<Map<String,int>> recentActivity({int days = 14}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffMs = cutoff.millisecondsSinceEpoch;
    final rows = await db.rawQuery('SELECT ${AppDatabaseConstants.colDecisionCreatedAt} as created_at FROM ${AppDatabaseConstants.decisionsTable} WHERE ${AppDatabaseConstants.colDecisionCreatedAt} >= ?', [cutoffMs]);
    final counts = <String,int>{};
    for (final r in rows) {
      final ms = r['created_at'] is int ? r['created_at'] as int : (r['created_at'] as num?)?.toInt();
      if (ms == null) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
      final key = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    // Ensure keys for each day exist with 0 if none
    final result = <String,int>{};
    for (var i = days - 1; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      result[key] = counts[key] ?? 0;
    }
    return result;
  }
}
