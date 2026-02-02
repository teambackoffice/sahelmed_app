import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sahelmed_app/config/api_constant.dart';

class CreateMaterialRequestService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.material_request.create_material_request';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createMaterialRequest({
    required String materialRequestType,
    required String company,
    required String setWarehouse,
    required String scheduleDate,
    required List<Map<String, dynamic>> items,
  }) async {
    // 🔐 Read credentials (SAME as CreateLeadService)
    final apiKey = await _storage.read(key: 'api_key');
    final apiSecret = await _storage.read(key: 'api_secret');
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null && (apiKey == null || apiSecret == null)) {
      throw Exception('Session expired. Please login again.');
    }

    // ✅ Build headers
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (apiKey != null && apiSecret != null) {
      headers['Authorization'] = 'token $sessionId';
    } else if (sessionId != null) {
      headers['Cookie'] = 'sid=$sessionId';
    }

    // ✅ Create request
    final request = http.Request('POST', Uri.parse(_url));
    request.headers.addAll(headers);
    request.body = json.encode({
      "material_request_type": materialRequestType,
      "company": company,
      "set_warehouse": setWarehouse,
      "required_date": scheduleDate,
      "items": items,
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    try {
      final decoded = json.decode(responseBody);

      if (response.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response format');
    }
  }
}
