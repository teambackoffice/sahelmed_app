import 'package:flutter/material.dart';
import '../services/logout_service.dart';

class LogoutController extends ChangeNotifier {
  final LogoutService _logoutService = LogoutService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _logoutService.logout();

    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Logout failed';
      notifyListeners();
      return false;
    }
  }
}
