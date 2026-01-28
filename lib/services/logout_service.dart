import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';

class LogoutService {
  static const String _logoutUrl =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.auth.logout';

  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> logout() async {
    try {
      // Get credentials for dynamic token
      final apiKey = await _storage.read(key: 'api_key');
      final apiSecret = await _storage.read(key: 'api_secret');
      final sessionId = await _storage.read(key: 'session_id');

      if (sessionId != null || (apiKey != null && apiSecret != null)) {
        final headers = <String, String>{'Content-Type': 'application/json'};

        if (apiKey != null && apiSecret != null) {
          headers['Authorization'] = 'token $apiKey:$apiSecret';
        } else if (sessionId != null) {
          headers['Cookie'] = 'sid=$sessionId';
        }

        final request = http.Request('POST', Uri.parse(_logoutUrl));
        request.headers.addAll(headers);

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        // Always clear storage to ensure user can logout locally
        await _storage.deleteAll();

        if (response.statusCode == 200) {
          try {
            final decodedBody = json.decode(responseBody);
            return {'success': true, 'data': decodedBody};
          } catch (e) {
            return {'success': true, 'message': 'Logged out locally'};
          }
        } else {
          // Verify if we can parse the error
          try {
            final decodedBody = json.decode(responseBody);
            return {
              'success': true,
              'message':
                  decodedBody['message'] ??
                  'Logged out locally with server error',
            };
          } catch (_) {
            return {'success': true, 'message': 'Logged out locally'};
          }
        }
      } else {
        // No credentials, just clear local storage
        await _storage.deleteAll();
        return {'success': true, 'message': 'Logged out locally'};
      }
    } catch (e) {
      // Force logout on exception
      await _storage.deleteAll();
      return {'success': true, 'message': 'Logged out locally (Error: $e)'};
    }
  }
}
