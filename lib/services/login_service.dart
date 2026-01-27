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

      debugPrint('➡️ LOGIN REQUEST BODY: ${request.body}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('⬅️ STATUS CODE: ${response.statusCode}');
      debugPrint('⬅️ RAW RESPONSE: $responseBody');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);

        /// 🔥 PRINT FULL RESPONSE (PRETTY JSON)
        debugPrint(
          '✅ LOGIN RESPONSE:\n${const JsonEncoder.withIndent('  ').convert(decoded)}',
        );

        /// Store full response
        await _storage.write(key: 'login_response', value: jsonEncode(decoded));

        final message = decoded['message'];

        if (message != null && message is Map<String, dynamic>) {
          /// API Credentials
          await _writeIfNotNull('api_key', message['api_key']);
          await _writeIfNotNull('api_secret', message['api_secret']);
          await _writeIfNotNull('session_id', message['session_id']);

          debugPrint('🔑 API KEY: ${message['api_key']}');
          debugPrint('🔑 API SECRET: ${message['api_secret']}');
          debugPrint('🆔 SESSION ID: ${message['session_id']}');

          /// User Info
          final userInfo = message['user_info'];
          if (userInfo != null) {
            await _storage.write(key: 'user_info', value: jsonEncode(userInfo));

            await _writeIfNotNull('user_id', userInfo['user_id']);
            await _writeIfNotNull('full_name', userInfo['full_name']);
            await _writeIfNotNull('email', userInfo['email']);
            await _writeIfNotNull('user_image', userInfo['user_image']);

            debugPrint(
              '👤 USER INFO:\n${const JsonEncoder.withIndent('  ').convert(userInfo)}',
            );
          }

          /// Roles
          final roles = message['roles'];
          if (roles != null && roles is List) {
            await _storage.write(key: 'roles', value: jsonEncode(roles));
            debugPrint('🎭 ROLES: $roles');
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

            debugPrint(
              '🔐 PERMISSIONS:\n${const JsonEncoder.withIndent('  ').convert(permissions)}',
            );
          }
        }

        /// Home Page
        if (decoded['home_page'] != null) {
          await _storage.write(
            key: 'home_page',
            value: decoded['home_page'].toString(),
          );
          debugPrint('🏠 HOME PAGE: ${decoded['home_page']}');
        }

        /// 🔐 PRINT EVERYTHING STORED
        await printAllStoredValues();

        return decoded;
      } else {
        debugPrint('❌ LOGIN FAILED');
        debugPrint('STATUS CODE: ${response.statusCode}');
        debugPrint('ERROR BODY: $responseBody');

        final errorBody = jsonDecode(responseBody);
        throw Exception(errorBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('🚨 LOGIN EXCEPTION: $e');
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

    debugPrint('🔐 ===== SECURE STORAGE DUMP START =====');
    allValues.forEach((key, value) {
      debugPrint('$key : $value');
    });
    debugPrint('🔐 ===== SECURE STORAGE DUMP END =====');
  }

  /// ============================
  /// GETTERS
  /// ============================
  Future<String?> getApiKey() async {
    final value = await _storage.read(key: 'api_key');
    debugPrint('GET api_key: $value');
    return value;
  }

  Future<String?> getApiSecret() async {
    final value = await _storage.read(key: 'api_secret');
    debugPrint('GET api_secret: $value');
    return value;
  }

  Future<String?> getSessionId() async {
    final value = await _storage.read(key: 'session_id');
    debugPrint('GET session_id: $value');
    return value;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final data = await _storage.read(key: 'user_info');
    debugPrint('GET user_info: $data');
    return data != null ? jsonDecode(data) : null;
  }

  Future<List<String>> getRoles() async {
    final data = await _storage.read(key: 'roles');
    debugPrint('GET roles: $data');
    if (data != null) {
      return List<String>.from(jsonDecode(data));
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPermissions() async {
    final data = await _storage.read(key: 'permissions');
    debugPrint('GET permissions: $data');
    return data != null ? jsonDecode(data) : null;
  }

  Future<bool> isServiceEngineer() async {
    final value = await _storage.read(key: 'is_service_engineer');
    debugPrint('is_service_engineer: $value');
    return value == 'true';
  }

  Future<bool> isSystemManager() async {
    final value = await _storage.read(key: 'is_system_manager');
    debugPrint('is_system_manager: $value');
    return value == 'true';
  }

  Future<String?> getFullName() async {
    final value = await _storage.read(key: 'full_name');
    debugPrint('GET full_name: $value');
    return value;
  }

  Future<bool> isLoggedIn() async {
    final sessionId = await _storage.read(key: 'session_id');
    debugPrint('CHECK login, session_id: $sessionId');
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getLoginResponse() async {
    final data = await _storage.read(key: 'login_response');
    debugPrint('GET login_response: $data');
    return data != null ? jsonDecode(data) : null;
  }

  /// ============================
  /// LOGOUT
  /// ============================
  Future<void> logout() async {
    debugPrint('🚪 LOGOUT – clearing storage');
    await _storage.deleteAll();
  }
}
