import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/get_mv_modal.dart';

import '../config/api_constant.dart';

class GetMaintenanceVisitService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.maintenance_visit.get_maintenance_visits';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetMaintenenceVisitModalClass> getMaintenanceRequests() async {
    // 🔐 Read SID from secure storage
    final String? sessionId = await _storage.read(key: 'session_id');

    final headers = {
      if (sessionId != null) 'Cookie': 'sid=$sessionId',
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse(_url).replace(queryParameters: {'limit': 'all'});

    final request = http.Request('GET', uri);
    request.headers.addAll(headers);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return getMaintenenceVisitModalClassFromJson(responseBody);
    } else {
      throw Exception(
        '❌ Failed to fetch maintenance visits\n'
        'Status: ${response.statusCode}\n'
        'Reason: ${response.reasonPhrase}\n'
        'Body: $responseBody',
      );
    }
  }
}
