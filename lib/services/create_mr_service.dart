import 'dart:convert';
import 'dart:developer' as developer;

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
    final apiKey = await _storage.read(key: 'api_key');
    final apiSecret = await _storage.read(key: 'api_secret');
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null && (apiKey == null || apiSecret == null)) {
      throw Exception('Session expired. Please login again.');
    }

    final headers = <String, String>{'Content-Type': 'application/json'};

    if (apiKey != null && apiSecret != null) {
      headers['Authorization'] = 'token $apiKey:$apiSecret';
    } else if (sessionId != null) {
      headers['Cookie'] = 'sid=$sessionId';
    }

    final body = {
      "material_request_type": materialRequestType,
      "company": company,
      "set_warehouse": setWarehouse,
      "required_date": scheduleDate,
      "items": items,
    };

    final request = http.Request('POST', Uri.parse(_url));
    request.headers.addAll(headers);
    request.body = jsonEncode(body);

    // ================= REQUEST LOG =================
    developer.log("========== API REQUEST ==========");
    developer.log("URL: ${request.url}");
    developer.log("Method: ${request.method}");
    developer.log("Headers: ${request.headers}");
    developer.log("Body: ${request.body}");
    developer.log("=================================");

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // ================= RESPONSE LOG =================
      developer.log("========== API RESPONSE ==========");
      developer.log("Status Code: ${response.statusCode}");
      developer.log("Response Headers: ${response.headers}");
      developer.log("Response Body: $responseBody");
      developer.log("==================================");

      if (responseBody.isEmpty) {
        throw Exception('Empty response body');
      }

      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(
          decoded['message'] ??
              'Request failed with status ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        "========== API ERROR ==========",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
