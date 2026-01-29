import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sahelmed_app/modal/create_quotation_response.dart';
import '../config/api_constant.dart';

class CreateQuotationService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.quotation.create_quotation';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<QuotationResponse> createQuotation({
    required String partyName,
    required List<Map<String, dynamic>> items,
  }) async {
    print('🚀 CREATE QUOTATION SERVICE STARTED');
    print('🌐 API URL: $_url');

    // 🔐 Read credentials
    final apiKey = await _storage.read(key: 'api_key');
    final apiSecret = await _storage.read(key: 'api_secret');
    final sessionId = await _storage.read(key: 'session_id');

    print('🔐 apiKey: $apiKey');
    print('🔐 apiSecret: ${apiSecret != null ? '****' : null}');
    print('🍪 sessionId: $sessionId');

    if (sessionId == null && (apiKey == null || apiSecret == null)) {
      print('❌ No valid authentication found');
      throw Exception('Session expired. Please login again.');
    }

    // Headers
    final headers = <String, String>{};

    if (apiKey != null && apiSecret != null) {
      headers['Authorization'] = 'token $apiKey:$apiSecret';
      print('✅ Using TOKEN authentication');
    } else if (sessionId != null) {
      headers['Cookie'] = 'sid=$sessionId';
      print('✅ Using SESSION authentication');
    }

    print('📤 REQUEST HEADERS: $headers');

    final request = http.MultipartRequest('POST', Uri.parse(_url));
    request.headers.addAll(headers);

    request.fields['quotation_to'] = "Customer";
    request.fields['party_name'] = partyName;

    print('📦 FIELD quotation_to: Customer');
    print('📦 FIELD party_name: $partyName');

    List<Map<String, dynamic>> processedItems = [];

    print('📋 RAW ITEMS COUNT: ${items.length}');

    for (int i = 0; i < items.length; i++) {
      final itemMap = Map<String, dynamic>.from(items[i]);
      print('➡️ Processing item $i: $itemMap');

      if (itemMap.containsKey('image_file') && itemMap['image_file'] is File) {
        final File imageFile = itemMap['image_file'];
        final String fileName = imageFile.path.split('/').last;

        print('🖼️ Image detected: $fileName');

        itemMap['image_view'] = fileName;

        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            imageFile.path,
            filename: fileName,
          ),
        );

        print('📎 Image attached to request');

        itemMap.remove('image_file');
      }

      processedItems.add(itemMap);
    }

    final itemsJson = json.encode(processedItems);
    request.fields['items'] = itemsJson;

    print('🧾 FINAL ITEMS JSON: $itemsJson');
    print('📎 TOTAL FILES ATTACHED: ${request.files.length}');
    print('📤 SENDING REQUEST...');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('📥 RESPONSE STATUS CODE: ${response.statusCode}');
    print('📥 RESPONSE BODY: $responseBody');

    try {
      final decoded = json.decode(responseBody);
      final messageData = decoded['message'];

      // Check if 'message' is a map and has a 'success' field
      if (messageData is Map<String, dynamic> &&
          messageData['success'] == false) {
        print('❌ API ERROR: ${messageData['message']}');
        throw Exception(messageData['message'] ?? 'Failed to create quotation');
      }

      if (response.statusCode == 200) {
        print('✅ QUOTATION CREATED SUCCESSFULLY');
        return quotationResponseFromJson(responseBody);
      } else {
        print('❌ API ERROR: ${decoded['message']}');
        throw Exception(decoded['message'] ?? 'Failed to create quotation');
      }
    } catch (e) {
      print('❌ RESPONSE PARSE ERROR: $e');
      // Rethrow if it's already an exception we threw, otherwise wrap
      if (e.toString().contains('Failed to create quotation')) {
        rethrow;
      }
      throw Exception('Failed to parse response: $e');
    }
  }
}
