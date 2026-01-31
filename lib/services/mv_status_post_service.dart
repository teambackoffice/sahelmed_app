import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sahelmed_app/config/api_constant.dart';

class UpdateVisitStatusService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.maintenance_visit.update_visit_status';

  Future<Map<String, dynamic>> updateVisitStatus({
    required String visitId,
    required String visitStatus,
  }) async {
    final FlutterSecureStorage storage = const FlutterSecureStorage();

    final sessionId = await storage.read(key: 'session_id');

    final headers = {
      'Authorization': 'token $sessionId',
      'Cookie': 'sid=$sessionId',
      'Content-Type': 'application/json',
    };

    final request = http.Request('POST', Uri.parse(_url));
    request.headers.addAll(headers);

    request.body = json.encode({
      "visit_id": visitId,
      "custom_visit_status": visitStatus,
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(responseBody);
      return decodedResponse;
    } else {
      throw Exception(
        'Failed to update visit status: ${response.reasonPhrase}',
      );
    }
  }
}
