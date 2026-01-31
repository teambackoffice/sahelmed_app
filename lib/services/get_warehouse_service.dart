import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_constant.dart';
import '../modal/get_warehouse_modal.dart';

class GetWarehouseService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.warehouse.get_warehouses';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetWareHouseModalClass> getWarehouses() async {
    try {
      // 🔑 Get sid from secure storage
      final String? sid = await _storage.read(key: 'session_id');

      if (sid == null || sid.isEmpty) {
        throw Exception('Session expired. Please login again.');
      }

      final response = await http.get(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      );

      if (response.statusCode == 200) {
        // Optional: pretty print JSON
        final decoded = jsonDecode(response.body);

        return getWareHouseModalClassFromJson(response.body);
      } else {
        throw Exception(
          'Failed to load warehouses (${response.statusCode})\n${response.body}',
        );
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
