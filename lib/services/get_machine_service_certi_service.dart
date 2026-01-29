import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/get_machine_service_modal.dart';
import '../config/api_constant.dart';

class GetMachineServiceService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.machine_service_certificate.get_machine_service_certificates';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetMachineServiceModalClass> fetchMachineServiceCertificates() async {
    // 🔐 Read session_id from secure storage
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null) {
      throw Exception('Session expired. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'sid=$sessionId',
    };

    final request = http.Request('GET', Uri.parse(_url));
    request.headers.addAll(headers);

    // 📤 PRINT REQUEST DETAILS
    print('📤 REQUEST URL: $_url');
    print('📤 REQUEST HEADERS: $headers');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // 📥 PRINT RESPONSE DETAILS
    print('📥 STATUS CODE: ${response.statusCode}');
    print('📥 REASON PHRASE: ${response.reasonPhrase}');
    print('📥 RESPONSE HEADERS: ${response.headers}');
    print('📥 RESPONSE BODY: $responseBody');

    if (response.statusCode == 200) {
      return getMachineServiceModalClassFromJson(responseBody);
    } else {
      throw Exception(
        'Failed to load machine service certificates: ${response.reasonPhrase}',
      );
    }
  }
}
