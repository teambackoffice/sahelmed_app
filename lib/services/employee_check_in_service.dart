import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahelmed_app/config/api_constant.dart';

enum CheckType { checkIn, checkOut }

class EmployeeCheckinService {
  static const String _baseUrl =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api';

  Future<Map<String, dynamic>> submitCheck({
    required CheckType type,
    required String token,
    required String employee,
    required String time,
    required String latitude,
    required String longitude,
  }) async {
    final String endpoint = type == CheckType.checkIn
        ? 'employee_checkin.create_employee_checkin'
        : 'employee_checkin.create_employee_checkout';

    final uri = Uri.parse('$_baseUrl.$endpoint');

    final headers = {
      'Authorization': 'token $token',
      'Content-Type': 'application/json',
      "Cookie": "sid=$token",
    };

    final body = jsonEncode({
      "employee": employee,
      "time": time,
      "latitude": latitude,
      "longitude": longitude,
    });

    final request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..body = body;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (responseBody.isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        return decoded;
      } catch (e) {
        throw Exception('Invalid JSON response');
      }
    } else {
      throw Exception('Empty response body');
    }
  }
}
