import 'package:flutter/material.dart';
import 'package:sahelmed_app/services/login_service.dart';

class LoginProvider extends ChangeNotifier {
  final LoginService _authService = LoginService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? loginData;
  List<String> userRoles = [];
  Map<String, dynamic>? permissions;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      loginData = await _authService.login(email: email, password: password);

      // Extract roles and permissions
      final message = loginData?['message'];
      if (message != null) {
        if (message['roles'] != null) {
          userRoles = List<String>.from(message['roles']);
        }
        permissions = message['permissions'];
      }

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Determine user's primary role for navigation
  String? getPrimaryRole() {
    if (permissions != null) {
      if (permissions!['is_service_engineer'] == true) {
        return 'Service Engineer';
      } else if (permissions!['is_system_manager'] == true) {
        return 'Service Manager';
      }
    }

    // Fallback to roles array
    if (userRoles.contains('Service Engineer')) {
      return 'Service Engineer';
    } else if (userRoles.contains('Service Manager')) {
      return 'Service Manager';
    }

    return null;
  }

  bool hasRole(String role) {
    return userRoles.contains(role);
  }

  void logout() async {
    await _authService.logout();
    loginData = null;
    userRoles = [];
    permissions = null;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        userRoles = await _authService.getRoles();
        permissions = await _authService.getPermissions();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }
    return false;
  }
}
