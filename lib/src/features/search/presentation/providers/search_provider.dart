import 'package:flutter/foundation.dart';

import '../../../../core/database/database_service.dart';
import '../../../decisions/data/models/decision_model.dart';
import '../../../decisions/data/models/journal_model.dart';
import '../../../decisions/data/models/history_model.dart';
import '../../../decisions/data/repositories/decision_repository.dart';
import '../../../decisions/data/repositories/journal_repository.dart';
import '../../../decisions/data/repositories/history_repository.dart';

class SearchProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<DecisionModel> _decisions = [];
  List<JournalModel> _journals = [];
  List<HistoryModel> _history = [];

  List<DecisionModel> get decisions => List.unmodifiable(_decisions);
  List<JournalModel> get journals => List.unmodifiable(_journals);
  List<HistoryModel> get history => List.unmodifiable(_history);

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _error;
  String? get errorMessage => _error;

  Future<void> searchAll(String query, {int limit = 200}) async {
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      final db = await _databaseService.database;
      final decisionRepo = DecisionRepository(db);
      final journalRepo = JournalRepository(db);
      final historyRepo = HistoryRepository(db);

      final results = await Future.wait([
        decisionRepo.getAll(includeArchived: true, searchQuery: query),
        journalRepo.getAll(limit: limit, searchQuery: query),
        historyRepo.getAll(limit: limit, searchQuery: query),
      ]);

      _decisions = results[0] as List<DecisionModel>;
      _journals = results[1] as List<JournalModel>;
      _history = results[2] as List<HistoryModel>;
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clear() {
    _decisions = [];
    _journals = [];
    _history = [];
    _error = null;
    notifyListeners();
  }
}
