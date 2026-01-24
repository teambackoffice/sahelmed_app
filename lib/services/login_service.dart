import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';

class LoginService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _loginUrl =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.auth.login';

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

        // Store entire response
        await _storage.write(key: 'login_response', value: jsonEncode(decoded));

        // Extract message object
        final message = decoded['message'];

        if (message != null && message is Map<String, dynamic>) {
          // Store API credentials
          if (message['api_key'] != null) {
            await _storage.write(
              key: 'api_key',
              value: message['api_key'].toString(),
            );
          }

          if (message['api_secret'] != null) {
            await _storage.write(
              key: 'api_secret',
              value: message['api_secret'].toString(),
            );
          }

          if (message['session_id'] != null) {
            await _storage.write(
              key: 'session_id',
              value: message['session_id'].toString(),
            );
          }

          // Store user info
          final userInfo = message['user_info'];
          if (userInfo != null) {
            await _storage.write(key: 'user_info', value: jsonEncode(userInfo));

            await _storage.write(
              key: 'user_id',
              value: userInfo['user_id'].toString(),
            );

            await _storage.write(
              key: 'full_name',
              value: userInfo['full_name'].toString(),
            );

            if (userInfo['email'] != null) {
              await _storage.write(
                key: 'email',
                value: userInfo['email'].toString(),
              );
            }

            if (userInfo['user_image'] != null) {
              await _storage.write(
                key: 'user_image',
                value: userInfo['user_image'].toString(),
              );
            }
          }

          // Store roles array
          final roles = message['roles'];
          if (roles != null && roles is List) {
            await _storage.write(key: 'roles', value: jsonEncode(roles));
          }

          // Store permissions
          final permissions = message['permissions'];
          if (permissions != null) {
            await _storage.write(
              key: 'permissions',
              value: jsonEncode(permissions),
            );

            // Store specific permission flags
            await _storage.write(
              key: 'is_service_engineer',
              value: permissions['is_service_engineer'].toString(),
            );

            await _storage.write(
              key: 'is_system_manager',
              value: permissions['is_system_manager'].toString(),
            );
          }
        }

        // Store home page
        if (decoded['home_page'] != null) {
          await _storage.write(
            key: 'home_page',
            value: decoded['home_page'].toString(),
          );
        }

        return decoded;
      } else {
        final errorBody = jsonDecode(responseBody);
        throw Exception(
          errorBody['message'] ?? 'Login failed: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Get API Key
  Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }

  // Get API Secret
  Future<String?> getApiSecret() async {
    return await _storage.read(key: 'api_secret');
  }

  // Get Session ID
  Future<String?> getSessionId() async {
    return await _storage.read(key: 'session_id');
  }

  // Get User Info
  Future<Map<String, dynamic>?> getUserInfo() async {
    final userInfo = await _storage.read(key: 'user_info');
    if (userInfo != null) {
      return jsonDecode(userInfo);
    }
    return null;
  }

  // Get Roles
  Future<List<String>> getRoles() async {
    final roles = await _storage.read(key: 'roles');
    if (roles != null) {
      final List<dynamic> rolesList = jsonDecode(roles);
      return rolesList.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Get Permissions
  Future<Map<String, dynamic>?> getPermissions() async {
    final permissions = await _storage.read(key: 'permissions');
    if (permissions != null) {
      return jsonDecode(permissions);
    }
    return null;
  }

  // Check if user is Service Engineer
  Future<bool> isServiceEngineer() async {
    final value = await _storage.read(key: 'is_service_engineer');
    return value == 'true';
  }

  // Check if user is System Manager
  Future<bool> isSystemManager() async {
    final value = await _storage.read(key: 'is_system_manager');
    return value == 'true';
  }

  // Get Full Name
  Future<String?> getFullName() async {
    return await _storage.read(key: 'full_name');
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final sessionId = await _storage.read(key: 'session_id');
    return sessionId != null && sessionId.isNotEmpty;
  }

  // Get complete login response
  Future<Map<String, dynamic>?> getLoginResponse() async {
    final response = await _storage.read(key: 'login_response');
    if (response != null) {
      return jsonDecode(response);
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
