import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';
import 'package:sahelmed_app/modal/get_material_request_modal.dart';

class GetMachineRequestService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.material_request.get_material_requests';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetMaterialRequestModalClass> fetchMaterialRequests() async {
    // 🔐 Read session_id from secure storage
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null) {
      throw Exception('Session expired. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'sid=$sessionId',
    };

    final uri = Uri.parse(_url).replace(queryParameters: {});

    final request = http.Request('GET', uri);
    request.headers.addAll(headers);

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final parsedData = getMaterialRequestModalClassFromJson(responseBody);

      return parsedData;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Session expired.');
    } else {
      throw Exception(
        'Failed to fetch material requests: ${response.reasonPhrase}',
      );
    }
  }
}
