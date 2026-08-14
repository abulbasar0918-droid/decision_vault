import 'dart:developer' as developer;

/// Application logging helper for Decision Vault.
///
/// This utility centralizes logging behavior to make it easy to track
/// runtime information and debug issues while keeping verbose logging out of
/// business logic.
class AppLogger {
  AppLogger._();

  static void log(String message, {String name = 'DecisionVault'}) {
    developer.log(message, name: name);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'DecisionVault',
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
