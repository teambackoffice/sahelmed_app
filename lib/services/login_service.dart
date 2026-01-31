import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';

class LoginService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _loginUrl =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.auth.login';

  /// ============================
  /// LOGIN API
  /// ============================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = http.Request('POST', Uri.parse(_loginUrl));

      request.headers.addAll({'Content-Type': 'application/json'});

      request.body = jsonEncode({
        "usr": email,
        "pwd": password,
        "auth_method": "session",
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decoded = jsonDecode(responseBody);

      // Check if the response contains an error (even with 200 status)
      if (decoded['message'] != null && decoded['message'] is Map) {
        if (decoded['message']['success'] == false) {
          throw Exception(
            decoded['message']['message'] ?? 'Invalid credentials',
          );
        }
      }

      if (response.statusCode == 200) {
        /// Store full response
        await _storage.write(key: 'login_response', value: jsonEncode(decoded));

        final message = decoded['message'];

        if (message != null && message is Map<String, dynamic>) {
          /// API Credentials
          await _writeIfNotNull('api_key', message['api_key']);
          await _writeIfNotNull('api_secret', message['api_secret']);
          await _writeIfNotNull('session_id', message['session_id']);

          /// User Info
          final userInfo = message['user_info'];
          if (userInfo != null) {
            await _storage.write(key: 'user_info', value: jsonEncode(userInfo));

            await _writeIfNotNull('user_id', userInfo['user_id']);
            await _writeIfNotNull('full_name', userInfo['full_name']);
            await _writeIfNotNull('email', userInfo['email']);
            await _writeIfNotNull('user_image', userInfo['user_image']);
          }

          final employeeInfo = userInfo?['employee_info'];
          if (employeeInfo != null && employeeInfo is Map<String, dynamic>) {
            await _storage.write(
              key: 'employee_info',
              value: jsonEncode(employeeInfo),
            );

            /// Store employee name separately (HR-EMP-00002)
            await _writeIfNotNull('employee_name', employeeInfo['name']);

            /// (Optional but useful)
            await _writeIfNotNull(
              'employee_display_name',
              employeeInfo['employee_name'],
            );
            await _writeIfNotNull('employee_id', employeeInfo['employee_id']);
          }

          /// Roles
          final roles = message['roles'];
          if (roles != null && roles is List) {
            await _storage.write(key: 'roles', value: jsonEncode(roles));
          }

          /// Permissions
          final permissions = message['permissions'];
          if (permissions != null && permissions is Map<String, dynamic>) {
            await _storage.write(
              key: 'permissions',
              value: jsonEncode(permissions),
            );

            await _writeIfNotNull(
              'is_service_engineer',
              permissions['is_service_engineer'],
            );

            await _writeIfNotNull(
              'is_system_manager',
              permissions['is_system_manager'],
            );
          }
        }

        /// Home Page
        if (decoded['home_page'] != null) {
          await _storage.write(
            key: 'home_page',
            value: decoded['home_page'].toString(),
          );
        }

        /// 🔐 PRINT EVERYTHING STORED (uncomment for debugging)
        // await printAllStoredValues();

        return decoded;
      } else {
        // Handle non-200 status codes
        String errorMsg = 'Login failed';

        if (decoded['message'] != null) {
          if (decoded['message'] is Map &&
              decoded['message']['message'] != null) {
            errorMsg = decoded['message']['message'];
          } else if (decoded['message'] is String) {
            errorMsg = decoded['message'];
          }
        } else if (decoded['exc'] != null) {
          errorMsg = decoded['exc'];
        }

        throw Exception(errorMsg);
      }
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Clean up the error message
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      if (errorMsg.startsWith('Login error: Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Login error: Exception: ', '');
      }
      throw Exception(errorMsg);
    }
  }

  /// ============================
  /// STORAGE HELPERS
  /// ============================
  Future<void> _writeIfNotNull(String key, dynamic value) async {
    if (value != null) {
      await _storage.write(key: key, value: value.toString());
    }
  }

  Future<void> printAllStoredValues() async {
    final allValues = await _storage.readAll();

    debugPrint('========== STORED VALUES ==========');
    allValues.forEach((key, value) {
      debugPrint('$key : $value');
    });
    debugPrint('===================================');
  }

  /// ============================
  /// GETTERS
  /// ============================
  Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }

  Future<String?> getApiSecret() async {
    return await _storage.read(key: 'api_secret');
  }

  Future<String?> getSessionId() async {
    return await _storage.read(key: 'session_id');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<String?> getFullName() async {
    return await _storage.read(key: 'full_name');
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }

  Future<String?> getUserImage() async {
    return await _storage.read(key: 'user_image');
  }

  Future<String?> getEmployeeName() async {
    return await _storage.read(key: 'employee_name');
  }

  Future<String?> getEmployeeId() async {
    return await _storage.read(key: 'employee_id');
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final data = await _storage.read(key: 'user_info');
    return data != null ? jsonDecode(data) : null;
  }

  Future<Map<String, dynamic>?> getEmployeeInfo() async {
    final data = await _storage.read(key: 'employee_info');
    return data != null ? jsonDecode(data) : null;
  }

  Future<List<String>> getRoles() async {
    final data = await _storage.read(key: 'roles');
    if (data != null) {
      return List<String>.from(jsonDecode(data));
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPermissions() async {
    final data = await _storage.read(key: 'permissions');
    return data != null ? jsonDecode(data) : null;
  }

  Future<bool> isServiceEngineer() async {
    final value = await _storage.read(key: 'is_service_engineer');
    return value == 'true';
  }

  Future<bool> isSystemManager() async {
    final value = await _storage.read(key: 'is_system_manager');
    return value == 'true';
  }

  Future<bool> isLoggedIn() async {
    final sessionId = await _storage.read(key: 'session_id');
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getLoginResponse() async {
    final data = await _storage.read(key: 'login_response');
    return data != null ? jsonDecode(data) : null;
  }

  Future<String?> getHomePage() async {
    return await _storage.read(key: 'home_page');
  }

  /// ============================
  /// LOGOUT
  /// ============================
  Future<void> logout() async {
    await _storage.deleteAll();
    debugPrint('User logged out - all data cleared');
  }

  /// ============================
  /// CLEAR SPECIFIC DATA
  /// ============================
  Future<void> clearUserData() async {
    await _storage.delete(key: 'user_info');
    await _storage.delete(key: 'employee_info');
    await _storage.delete(key: 'roles');
    await _storage.delete(key: 'permissions');
  }

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: 'api_key');
    await _storage.delete(key: 'api_secret');
    await _storage.delete(key: 'session_id');
  }
}
