import 'package:flutter/foundation.dart';

/// A reusable base provider for all ChangeNotifier providers in Decision Vault.
///
/// This class consolidates loading and error state handling so feature providers
/// can remain focused on business logic.
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @protected
  void setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  @protected
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  @protected
  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
