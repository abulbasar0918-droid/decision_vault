/// A base repository that defines the contract for all repository implementations.
///
/// Concrete feature repositories should extend this class and implement
/// initialization and cleanup as necessary.
abstract class BaseRepository {
  /// Initialize any resources required by the repository.
  Future<void> init();

  /// Dispose repository resources if needed.
  Future<void> dispose() async {}
}
