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

            await _writeIfNotNull('employee_name', employeeInfo['name']);
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

        return decoded;
      } else {
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

    allValues.forEach((key, value) {});
  }

  /// ============================
  /// GETTERS
  /// ============================
  Future<String?> getApiKey() async {
    final value = await _storage.read(key: 'api_key');
  }

  Future<String?> getApiSecret() async {
    final value = await _storage.read(key: 'api_secret');
    return value;
  }

  Future<String?> getSessionId() async {
    final value = await _storage.read(key: 'session_id');
    return value;
  }

  Future<bool> isLoggedIn() async {
    final sessionId = await _storage.read(key: 'session_id');
    return sessionId != null && sessionId.isNotEmpty;
  }

  /// ============================
  /// LOGOUT
  /// ============================
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// ============================
  /// GET ROLES
  /// ============================
  Future<List<String>> getRoles() async {
    final data = await _storage.read(key: 'roles');

    if (data != null) {
      try {
        return List<String>.from(jsonDecode(data));
      } catch (e) {}
    }

    return [];
  }

  /// ============================
  /// GET PERMISSIONS
  /// ============================
  Future<Map<String, dynamic>?> getPermissions() async {
    final data = await _storage.read(key: 'permissions');

    if (data != null) {
      try {
        return jsonDecode(data);
      } catch (e) {}
    }

    return null;
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
