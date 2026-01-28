import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/get_customer_modal.dart';
import '../config/api_constant.dart';

class GetCustomerService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.customers.get_customers?disabled=0';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<CustomerResponse> fetchCustomers() async {
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null) {
      throw Exception('Session expired. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'sid=$sessionId',
    };

    print('🔵 REQUEST URL: $_url');
    print('🔵 REQUEST HEADERS: $headers');

    final response = await http.get(Uri.parse(_url), headers: headers);

    // 🔽 PRINT EVERYTHING
    print('🟢 STATUS CODE: ${response.statusCode}');
    print('🟢 RESPONSE HEADERS: ${response.headers}');
    print('🟢 RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      return customerResponseFromJson(response.body);
    } else {
      throw Exception(
        'Failed to fetch customers | Status: ${response.statusCode}',
      );
    }
  }
}
