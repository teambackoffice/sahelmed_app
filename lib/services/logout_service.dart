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
      final headers = {
        'Authorization': 'token a255fc09fc28806:3247e06720bb239',
        'Content-Type': 'application/json',
      };

      final request = http.Request('POST', Uri.parse(_logoutUrl));
      request.headers.addAll(headers);

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (responseBody.isNotEmpty) {
        try {
          final decodedBody = json.decode(responseBody);

          if (response.statusCode == 200) {
            // Clear local storage after successful logout
            await _storage.deleteAll();

            return {'success': true, 'data': decodedBody};
          } else {
            return {
              'success': false,
              'message': decodedBody['message'] ?? 'Logout failed',
              'statusCode': response.statusCode,
            };
          }
        } catch (jsonError) {
          return {
            'success': false,
            'message': 'Invalid JSON response',
            'rawResponse': responseBody,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
