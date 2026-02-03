import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mime/mime.dart';

import '../config/api_constant.dart';
import '../modal/create_quotation_response.dart';

class CreateQuotationService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.quotation.create_quotation';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<QuotationResponse> createQuotation({
    required String quotationTo,
    required String partyName,
    required List<Map<String, dynamic>> items,
    String? transactionDate,
    String? validTill,
    String? orderType,
  }) async {
    // 🔐 AUTH DATA
    final apiKey = await _storage.read(key: 'api_key');
    final apiSecret = await _storage.read(key: 'api_secret');
    final sessionId = await _storage.read(key: 'session_id');

    if (apiKey == null && apiSecret == null && sessionId == null) {
      throw Exception('Session expired. Please login again.');
    }

    // 🔹 PREPARE ITEMS
    List<Map<String, dynamic>> finalItems = [];

    for (int i = 0; i < items.length; i++) {
      final item = Map<String, dynamic>.from(items[i]);

      // 📷 IMAGE HANDLING
      if (item.containsKey('image_file') && item['image_file'] is File) {
        final File imageFile = item['image_file'];
        final String fileName = imageFile.path.split('/').last;

        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();

          final mimeType =
              lookupMimeType(imageFile.path, headerBytes: bytes) ??
              'image/jpeg';

          final base64Image = base64Encode(bytes);
          final dataUri = 'data:$mimeType;base64,$base64Image';

          item['image_b64'] = dataUri;
          item['image_filename'] = fileName;

          item.remove('image');
          item.remove('image_file');
        }
      }

      finalItems.add(item);
    }

    // 🔐 HEADERS
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (apiKey != null && apiSecret != null) {
      headers['Authorization'] = 'token $apiKey:$apiSecret';
    } else if (sessionId != null) {
      headers['Authorization'] = 'token $sessionId';
      headers['Cookie'] = 'sid=$sessionId';
    }

    // 🔹 BODY
    final body = {
      'quotation_to': quotationTo,
      'party_name': partyName,
      'items': finalItems,
    };

    if (transactionDate != null) {
      body['transaction_date'] = transactionDate;
    }
    if (validTill != null) {
      body['valid_till'] = validTill;
    }
    if (orderType != null) {
      body['order_type'] = orderType;
    }

    final jsonBody = jsonEncode(body);

    // 🚀 API CALL
    final response = await http.post(
      Uri.parse(_url),
      headers: headers,
      body: jsonBody,
    );

    return _handleResponse(response.statusCode, response.body);
  }

  // ================= RESPONSE HANDLER =================

  QuotationResponse _handleResponse(int statusCode, String responseBody) {
    try {
      final decoded = json.decode(responseBody);
    } catch (e) {}

    if (statusCode == 200) {
      final decoded = json.decode(responseBody);

      if (decoded['message'] != null && decoded['message'] is Map) {
        final msg = decoded['message'];

        if (msg['success'] == false) {
          final errorMsg = msg['message'] ?? 'Quotation creation failed';
          final errorDetails = msg['error_details'];

          if (errorDetails != null) {
            throw Exception('$errorMsg: $errorDetails');
          } else {
            throw Exception(errorMsg);
          }
        }
      }

      return quotationResponseFromJson(responseBody);
    }

    if (statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    }

    try {
      final decoded = json.decode(responseBody);
      final errorMsg =
          decoded['message'] ??
          decoded['error'] ??
          decoded['exc'] ??
          'Quotation creation failed';

      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Server error: $statusCode');
    }
  }
}
