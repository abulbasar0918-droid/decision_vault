import '../../../../core/database/database_service.dart';
import '../../../../core/provider/base_provider.dart';
import '../../data/models/decision_model.dart';
import '../../data/repositories/decision_repository.dart';

class DecisionProvider extends BaseProvider {
  DecisionProvider();

  final DatabaseService _databaseService = DatabaseService.instance;
  DecisionRepository? _repository;
  final List<DecisionModel> _decisions = <DecisionModel>[];

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedTag;
  bool _showFavoritesOnly = false;
  bool _showArchivedOnly = false;
  bool _initialized = false;

  List<DecisionModel> get decisions => List<DecisionModel>.unmodifiable(_decisions);

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedTag => _selectedTag;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get showArchivedOnly => _showArchivedOnly;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedCategory != null || _selectedTag != null || _showFavoritesOnly || _showArchivedOnly;

  List<DecisionModel> get filteredDecisions {
    final query = _searchQuery.trim().toLowerCase();

    return _decisions.where((decision) {
      final matchesQuery = query.isEmpty ||
          decision.title.toLowerCase().contains(query) ||
          (decision.description?.toLowerCase().contains(query) ?? false) ||
          (decision.category?.toLowerCase().contains(query) ?? false) ||
          (decision.notes?.toLowerCase().contains(query) ?? false);

      final matchesCategory = _selectedCategory == null || decision.category == _selectedCategory;
      final matchesTag = _selectedTag == null || decision.tags.contains(_selectedTag);
      final matchesFavorite = !_showFavoritesOnly || decision.isFavorite;
      final matchesArchived = !_showArchivedOnly || decision.isArchived;

      return matchesQuery && matchesCategory && matchesTag && matchesFavorite && matchesArchived;
    }).toList(growable: false);
  }

  int get totalDecisions => _decisions.length;

  List<String> get tags {
    final tags = _decisions.expand((d) => d.tags).where((t) => t.trim().isNotEmpty).toSet().toList();
    tags.sort();
    return tags;
  }
  int get activeDecisions => _decisions.where((decision) => !decision.isArchived).length;
  int get favoriteDecisions => _decisions.where((decision) => decision.isFavorite).length;
  int get archivedDecisions => _decisions.where((decision) => decision.isArchived).length;

  List<String> get categories {
    final categories = _decisions
        .map((decision) => decision.category)
        .whereType<String>()
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      clearError();
      setLoading(true);
      await _databaseService.init();
      _repository ??= DecisionRepository(await _databaseService.database);
      await _repository!.init();
      await loadDecisions();
      _initialized = true;
    } catch (error) {
      setError('Unable to initialize decisions: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadDecisions() async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      final items = await repository.getAll(
        includeArchived: true,
        searchQuery: _searchQuery,
        category: _selectedCategory,
        favoriteOnly: _showFavoritesOnly ? true : null,
      );
      _decisions
        ..clear()
        ..addAll(items);
      notifyListeners();
    } catch (error) {
      setError('Unable to load decisions: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveDecision(DecisionModel decision) async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      final toSave = decision.copyWith(updatedAt: DateTime.now(), isDraft: false);
      if (toSave.id == null) {
        await repository.create(toSave);
      } else {
        await repository.update(toSave);
      }
      await loadDecisions();
    } catch (error) {
      setError('Unable to save decision: $error');
    } finally {
      setLoading(false);
    }
  }

  /// Save a draft version of the decision (auto-save). Drafts are marked with
  /// isDraft = true and will be visible to the user for continuation.
  Future<void> saveDraft(DecisionModel decision) async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      final toSave = decision.copyWith(updatedAt: DateTime.now(), isDraft: true);
      if (toSave.id == null) {
        await repository.create(toSave);
      } else {
        await repository.update(toSave);
      }
      await loadDecisions();
    } catch (error) {
      setError('Unable to save draft: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteDecision(int id) async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      await repository.delete(id);
      await loadDecisions();
    } catch (error) {
      setError('Unable to delete decision: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> toggleFavorite(int id) async {
    final decision = _decisions.whereType<DecisionModel>().firstWhere(
      (item) => item.id == id,
      orElse: () => throw StateError('Decision not found'),
    );
    final updated = decision.copyWith(isFavorite: !decision.isFavorite, updatedAt: DateTime.now());
    await _persistUpdate(updated);
  }

  Future<void> toggleArchive(int id) async {
    final decision = _decisions.whereType<DecisionModel>().firstWhere(
      (item) => item.id == id,
      orElse: () => throw StateError('Decision not found'),
    );
    final updated = decision.copyWith(isArchived: !decision.isArchived, updatedAt: DateTime.now());
    await _persistUpdate(updated);
  }

  Future<void> setSearchQuery(String value) async {
    _searchQuery = value;
    notifyListeners();
    await loadDecisions();
  }

  Future<void> setSelectedCategory(String? category) async {
    _selectedCategory = category;
    notifyListeners();
    await loadDecisions();
  }

  Future<void> setSelectedTag(String? tag) async {
    _selectedTag = tag;
    notifyListeners();
    await loadDecisions();
  }

  Future<void> setFavoritesOnly(bool value) async {
    _showFavoritesOnly = value;
    notifyListeners();
    await loadDecisions();
  }

  Future<void> setArchivedOnly(bool value) async {
    _showArchivedOnly = value;
    notifyListeners();
    await loadDecisions();
  }

  Future<void> resetFilters() async {
    _searchQuery = '';
    _selectedCategory = null;
    _showFavoritesOnly = false;
    _showArchivedOnly = false;
    notifyListeners();
    await loadDecisions();
  }

  Future<DecisionModel?> getDecisionById(int id) async {
    final repository = await _getRepository();
    return repository.getById(id);
  }

  Future<void> _persistUpdate(DecisionModel updatedDecision) async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      await repository.update(updatedDecision);
      await loadDecisions();
    } catch (error) {
      setError('Unable to update decision: $error');
    } finally {
      setLoading(false);
    }
  }

  /// Rename a category across all decisions that use [oldCategory].
  /// If [newCategory] is null or empty the category will be cleared.
  Future<void> renameCategory(String oldCategory, String? newCategory) async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      final updates = _decisions.where((d) => d.category == oldCategory).toList();
      for (final d in updates) {
        final updated = d.copyWith(category: (newCategory?.trim().isEmpty ?? true) ? null : newCategory, updatedAt: DateTime.now());
        await repository.update(updated);
      }
      await loadDecisions();
    } catch (error) {
      setError('Unable to rename category: $error');
    } finally {
      setLoading(false);
    }
  }

  /// Delete (clear) a category from decisions that reference it.
  Future<void> deleteCategory(String category) async {
    await renameCategory(category, null);
  }

  /// Rename a tag across all decisions that use [oldTag]. If [newTag] is null
  /// or empty the tag will be removed from decisions.
  Future<void> renameTag(String oldTag, String? newTag) async {
    try {
      clearError();
      setLoading(true);
      final repository = await _getRepository();
      final updates = _decisions.where((d) => d.tags.contains(oldTag)).toList();
      for (final d in updates) {
        final newTags = d.tags
            .map((t) => t == oldTag ? (newTag?.trim().isEmpty ?? true ? null : newTag) : t)
            .whereType<String>()
            .toSet()
            .toList();
        final updated = d.copyWith(tags: newTags, updatedAt: DateTime.now());
        await repository.update(updated);
      }
      await loadDecisions();
    } catch (error) {
      setError('Unable to rename tag: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteTag(String tag) async {
    await renameTag(tag, null);
  }

  Future<DecisionRepository> _getRepository() async {
    _repository ??= DecisionRepository(await _databaseService.database);
    return _repository!;
  }
}
