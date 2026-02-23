import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/get_item_list_modal.dart';
import '../config/api_constant.dart';

class GetItemsService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.items.get_items';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<ItemsResponse> fetchItems() async {
    final sessionId = await _storage.read(key: 'session_id');

    if (sessionId == null) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse(_url).replace(
      queryParameters: {'is_sales_item': '1', 'disabled': '0', 'limit': 'all'},
    );

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'sid=$sessionId',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return itemsResponseFromJson(response.body);
    } else {
      throw Exception(
        'Failed to load items | Status: ${response.statusCode} | Body: ${response.body}',
      );
    }
  }
}
