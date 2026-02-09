import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/config/api_constant.dart';
import 'package:sahelmed_app/modal/get_msc_count_modal.dart';

class GetMachineServiceCertificateCountService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.machine_service_certificate.get_machine_service_certificates_total_count';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<MachineServiceCertificateCountModel> getTotalCount() async {
    final String? sid = await _storage.read(key: 'session_id');

    final headers = {
      'Authorization': 'token $sid',
      'Cookie': 'sid=$sid',
      'Content-Type': 'application/json',
    };

    final request = http.Request('GET', Uri.parse(_url));
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);

      return MachineServiceCertificateCountModel.fromJson(decoded['message']);
    } else {
      throw Exception('Failed to fetch total count: ${response.reasonPhrase}');
    }
  }
}
