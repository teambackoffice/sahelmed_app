import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/get_mv_count_modal.dart';

import '../config/api_constant.dart';

class GetMvCountService {
  static const String _endpoint =
      'medservice_pro.medservice.api.maintenance_visit.get_maintenance_visits_total_count';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetMvCountModalClass> getMvCount() async {
    try {
      final String? sid = await _storage.read(key: 'session_id');

      if (sid == null || sid.isEmpty) {
        throw Exception('Authorization token (sid) not found');
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}$_endpoint?include_breakdown=1',
      );

      final headers = {
        'Authorization': 'token $sid',
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Optional: decode & print JSON nicely
        final decoded = jsonDecode(response.body);

        final model = getMvCountModalClassFromJson(response.body);

        return model;
      } else {
        throw Exception('Failed to fetch MV count (${response.statusCode})');
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
