import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahelmed_app/config/api_constant.dart';

class CreateLeadService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.lead.create_lead';

  static const Map<String, String> _headers = {
    'Authorization': 'token a255fc09fc28806:a7c61e9aa0fdeef',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> createLead({
    required String leadName,
    required String companyName,
    required String email,
    required String mobileNo,
    required String source,
  }) async {
    final request = http.Request('POST', Uri.parse(_url));

    request.headers.addAll(_headers);
    request.body = json.encode({
      "lead_name": leadName,
      "company_name": companyName,
      "email_id": email,
      "mobile_no": mobileNo,
      "source": source,
    });

    print('📤 REQUEST URL: $_url');
    print('📤 REQUEST HEADERS: $_headers');
    print('📤 REQUEST BODY: ${request.body}');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('📥 STATUS CODE: ${response.statusCode}');
    print('📥 RESPONSE HEADERS: ${response.headers}');
    print('📥 RAW RESPONSE BODY: $responseBody');

    // Try decoding JSON safely
    try {
      final decoded = json.decode(responseBody);
      print('📥 DECODED RESPONSE: $decoded');

      if (response.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(decoded);
      }
    } catch (e) {
      print('❌ JSON DECODE ERROR: $e');
      throw Exception('Invalid response format');
    }
  }
}
