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

    // 🔹 PREPARE ITEMS AND CONVERT IMAGES TO BASE64 DATA URI
    List<Map<String, dynamic>> finalItems = [];

    for (int i = 0; i < items.length; i++) {
      final item = Map<String, dynamic>.from(items[i]);

      // 📷 IMAGE HANDLING - Convert to Base64 Data URI
      if (item.containsKey('image_file')) {
        if (item['image_file'] is File) {
          final File imageFile = item['image_file'];
          final String fileName = imageFile.path.split('/').last;

          if (await imageFile.exists()) {
            // Read file as bytes
            final bytes = await imageFile.readAsBytes();

            // Detect MIME type
            final mimeType =
                lookupMimeType(imageFile.path, headerBytes: bytes) ??
                'image/jpeg';

            // Convert to base64
            final base64Image = base64Encode(bytes);

            // Create data URI (data:image/png;base64,...)
            final dataUri = 'data:$mimeType;base64,$base64Image';

            // Backend expects these exact field names
            item['image_b64'] = dataUri;
            item['image_filename'] = fileName;

            // Remove the old fields
            item.remove('image');
            item.remove('image_file');
          } else {}
        } else {}
      } else {}

      finalItems.add(item);
    }

    // ============= JSON POST REQUEST =============
    final headers = <String, String>{'Content-Type': 'application/json'};

    // 🔐 SET AUTHENTICATION HEADERS
    if (apiKey != null && apiSecret != null) {
      headers['Authorization'] = 'token $apiKey:$apiSecret';
    } else if (sessionId != null) {
      headers['Authorization'] = 'token $sessionId';
      headers['Cookie'] = 'sid=$sessionId';
    }

    // 🔹 BUILD JSON BODY (matching backend format exactly)
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

    if (finalItems.isNotEmpty && finalItems.first.containsKey('image_b64')) {
      final sampleItem = Map<String, dynamic>.from(finalItems.first);
      if (sampleItem['image_b64'] != null &&
          sampleItem['image_b64'].length > 100) {
        final b64String = sampleItem['image_b64'] as String;
        sampleItem['image_b64'] =
            '${b64String.substring(0, 50)}... [TRUNCATED ${b64String.length} chars]';
      }
    }

    // 🚀 SEND REQUEST
    final response = await http.post(
      Uri.parse(_url),
      headers: headers,
      body: jsonBody,
    );

    return _handleResponse(response.statusCode, response.body);
  }

  QuotationResponse _handleResponse(int statusCode, String responseBody) {
    // 🔍 TRY JSON DECODE
    try {
      final decoded = json.decode(responseBody);
    } catch (e) {}

    // ✅ HANDLE RESPONSE
    if (statusCode == 200) {
      final decoded = json.decode(responseBody);

      // Check if the response indicates success or error
      if (decoded['message'] != null && decoded['message'] is Map) {
        final msg = decoded['message'];

        if (msg['success'] == false) {
          // Backend returned an error
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
    } else if (statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
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
}
