import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/get_leads_modal.dart';
import 'package:sahelmed_app/config/api_constant.dart';

class LeadService {
  static const String _baseUrl =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.lead.get_leads';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetLeadModal> fetchLeads() async {
    final sid = await _storage.read(key: 'session_id');

    if (sid == null) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'limit': 'all'});

    final request = http.Request('GET', uri);

    // 🍪 Attach cookie
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Cookie': 'sid=$sid',
    });

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final parsedData = getLeadModalFromJson(responseBody);

      for (var lead in parsedData.message.leads) {}

      return parsedData;
    } else {
      throw Exception('Failed to load leads: ${response.reasonPhrase}');
    }
  }
}
