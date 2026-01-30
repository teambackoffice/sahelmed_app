import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';
import 'package:sahelmed_app/modal/get_quotation_modal.dart';

class GetQuotationService {
  static const String _baseUrl =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.quotation.get_quotations';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<GetQuotationModalClass> getQuotations() async {
    final sessionId = await _secureStorage.read(key: 'session_id');

    if (sessionId == null) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse(_baseUrl);

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sessionId'},
    );

    if (response.statusCode == 200) {
      return getQuotationModalClassFromJson(response.body);
    } else {
      throw Exception('Failed to fetch quotations (${response.statusCode})');
    }
  }
}
