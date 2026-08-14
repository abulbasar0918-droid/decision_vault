import '../../../../core/database/database_service.dart';
import '../../../../core/provider/base_provider.dart';
import '../../data/models/journal_model.dart';
import '../../data/repositories/journal_repository.dart';

class JournalProvider extends BaseProvider {
  JournalProvider();

  final DatabaseService _databaseService = DatabaseService.instance;
  JournalRepository? _repository;
  final List<JournalModel> _items = <JournalModel>[];

  List<JournalModel> get items => List<JournalModel>.unmodifiable(_items);

  Future<JournalRepository> _getRepository() async {
    _repository ??= JournalRepository(await _databaseService.database);
    return _repository!;
  }

  Future<List<JournalModel>> loadAll({int limit = 200}) async {
    try {
      clearError();
      setLoading(true);
      final repo = await _getRepository();
      final rows = await repo.getAll(limit: limit);
      _items
        ..clear()
        ..addAll(rows);
      notifyListeners();
      return _items;
    } catch (error) {
      setError('Unable to load journal entries: $error');
      return <JournalModel>[];
    } finally {
      setLoading(false);
    }
  }

  Future<JournalModel?> getById(int id) async {
    final repo = await _getRepository();
    return repo.getById(id);
  }

  Future<void> save(JournalModel model) async {
    try {
      clearError();
      setLoading(true);
      final repo = await _getRepository();
      if (model.id == null) {
        await repo.create(model);
      } else {
        await repo.update(model);
      }
      await loadAll();
    } catch (e) {
      setError('Unable to save journal entry: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> delete(int id) async {
    try {
      clearError();
      setLoading(true);
      final repo = await _getRepository();
      await repo.delete(id);
      await loadAll();
    } catch (e) {
      setError('Unable to delete journal entry: $e');
    } finally {
      setLoading(false);
    }
  }
}
