import '../../../../core/database/database_service.dart';
import '../../../../core/provider/base_provider.dart';
import '../../data/models/history_model.dart';
import '../../data/repositories/history_repository.dart';

class HistoryProvider extends BaseProvider {
  HistoryProvider();

  final DatabaseService _databaseService = DatabaseService.instance;
  HistoryRepository? _repository;
  final List<HistoryModel> _history = <HistoryModel>[];

  List<HistoryModel> get history => List<HistoryModel>.unmodifiable(_history);

  Future<HistoryRepository> _getRepository() async {
    _repository ??= HistoryRepository(await _databaseService.database);
    return _repository!;
  }

  /// Load history entries for a particular decision.
  Future<List<HistoryModel>> loadForDecision(int decisionId, {int limit = 200}) async {
    try {
      clearError();
      setLoading(true);
      final repo = await _getRepository();
      final items = await repo.getByDecisionId(decisionId, limit: limit);
      _history
        ..clear()
        ..addAll(items);
      notifyListeners();
      return _history;
    } catch (error) {
      setError('Unable to load history: $error');
      return <HistoryModel>[];
    } finally {
      setLoading(false);
    }
  }

  /// Load recent history across all decisions.
  Future<List<HistoryModel>> loadRecent({int limit = 200}) async {
    try {
      clearError();
      setLoading(true);
      final repo = await _getRepository();
      final items = await repo.getAll(limit: limit);
      _history
        ..clear()
        ..addAll(items);
      notifyListeners();
      return _history;
    } catch (error) {
      setError('Unable to load recent history: $error');
      return <HistoryModel>[];
    } finally {
      setLoading(false);
    }
  }
}
