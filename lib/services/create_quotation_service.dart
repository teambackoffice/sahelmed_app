import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/create_quotation_response.dart';
import '../config/api_constant.dart';

class CreateQuotationService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.quotation.create_quotation';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<QuotationResponse> createQuotation({
    required String partyName,
    required List<Map<String, dynamic>> items,
  }) async {
    // 🔐 Read credentials
    final apiKey = await _storage.read(key: 'api_key');
    final apiSecret = await _storage.read(key: 'api_secret');
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null && (apiKey == null || apiSecret == null)) {
      throw Exception('Session expired. Please login again.');
    }

    final headers = <String, String>{'Content-Type': 'application/json'};

    // ✅ Priority: Token auth → Session auth
    if (apiKey != null && apiSecret != null) {
      headers['Authorization'] = 'token $apiKey:$apiSecret';
    } else if (sessionId != null) {
      headers['Cookie'] = 'sid=$sessionId';
    }

    final request = http.Request('POST', Uri.parse(_url));
    request.headers.addAll(headers);

    request.body = json.encode({
      "quotation_to": "Customer",
      "party_name": partyName,
      "items": items,
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    try {
      final decoded = json.decode(responseBody);

      if (response.statusCode == 200) {
        return quotationResponseFromJson(responseBody);
      } else {
        throw Exception(decoded['message'] ?? 'Failed to create quotation');
      }
    } catch (e) {
      throw Exception('Invalid response format');
    }
  }
}
