import 'package:flutter/foundation.dart';
import '../../../../core/database/database_service.dart';
import '../../data/statistics_repository.dart';

class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider();

  final DatabaseService _databaseService = DatabaseService.instance;
  StatisticsRepository? _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;

  int total = 0;
  int active = 0;
  int archived = 0;
  int favorites = 0;

  Map<String,int> byCategory = {};
  Map<String,int> byTag = {};
  Map<int,int> priorityDistribution = {};
  double averageScore = 0.0;
  double sumScore = 0.0;
  Map<String,int> recentActivity = {};

  Future<StatisticsRepository> _getRepository() async {
    _repository ??= StatisticsRepository(await _databaseService.database);
    return _repository!;
  }

  Future<void> load({int activityDays = 14}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final repo = await _getRepository();

      final results = await Future.wait([
        repo.totalDecisions(),
        repo.activeDecisions(),
        repo.archivedDecisions(),
        repo.favoriteDecisions(),
        repo.decisionsByCategory(),
        repo.decisionsByTag(),
        repo.priorityDistribution(),
        repo.weightedScoreSummary(),
        repo.recentActivity(days: activityDays),
      ]);

      total = results[0] as int;
      active = results[1] as int;
      archived = results[2] as int;
      favorites = results[3] as int;
      byCategory = Map<String,int>.from(results[4] as Map);
      byTag = Map<String,int>.from(results[5] as Map);
      priorityDistribution = Map<int,int>.from(results[6] as Map);
      final summary = results[7] as Map<String,num>;
      sumScore = (summary['sum'] ?? 0).toDouble();
      averageScore = (summary['avg'] ?? 0).toDouble();
      recentActivity = Map<String,int>.from(results[8] as Map);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Unable to load statistics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    total = 0;
    active = 0;
    archived = 0;
    favorites = 0;
    byCategory = {};
    byTag = {};
    priorityDistribution = {};
    averageScore = 0.0;
    sumScore = 0.0;
    recentActivity = {};
    _error = null;
    notifyListeners();
  }
}
