import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';
import '../modal/get_mr_count_modal.dart';

class GetMaterialRequestCountService {
  static final String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.material_request.get_material_requests_total_count';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<MaterialRequestCountModel> getMaterialRequestCount() async {
    try {
      // 🔐 Read sid from secure storage
      final String? sid = await _secureStorage.read(key: 'session_id');

      if (sid == null || sid.isEmpty) {
        throw Exception('SID not found in secure storage');
      }

      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Authorization': "token $sid",
          'Cookie': 'sid=$sid',
          'Content-Type': 'application/json',
        },
      );

      // 🖨️ PRINT ALL RESPONSE DETAILS
      print('🔵 MR COUNT API URL: $_url');
      print('🔵 STATUS CODE: ${response.statusCode}');
      print('🔵 RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return MaterialRequestCountModel.fromJson(decoded['message']);
      } else {
        throw Exception(
          'Failed to load material request count | '
          'Status: ${response.statusCode} | '
          'Body: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('🔴 ERROR IN getMaterialRequestCount');
      print('🔴 ERROR: $e');
      print('🔴 STACKTRACE: $stackTrace');
      rethrow;
    }
  }
}
