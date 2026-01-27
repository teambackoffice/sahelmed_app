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

      request.body = jsonEncode({"usr": email, "pwd": password});

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);

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

        /// 🔐 PRINT EVERYTHING STORED
        await printAllStoredValues();

        return decoded;
      } else {
        final errorBody = jsonDecode(responseBody);
        throw Exception(errorBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
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

    allValues.forEach((key, value) {
      debugPrint('$key : $value');
    });
  }

  /// ============================
  /// GETTERS
  /// ============================
  Future<String?> getApiKey() async {
    final value = await _storage.read(key: 'api_key');
    return value;
  }

  Future<String?> getApiSecret() async {
    final value = await _storage.read(key: 'api_secret');
    return value;
  }

  Future<String?> getSessionId() async {
    final value = await _storage.read(key: 'session_id');
    return value;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final data = await _storage.read(key: 'user_info');
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

  Future<String?> getFullName() async {
    final value = await _storage.read(key: 'full_name');
    return value;
  }

  Future<bool> isLoggedIn() async {
    final sessionId = await _storage.read(key: 'session_id');
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getLoginResponse() async {
    final data = await _storage.read(key: 'login_response');
    return data != null ? jsonDecode(data) : null;
  }

  /// ============================
  /// LOGOUT
  /// ============================
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
