import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_constant.dart';

class CreateMachineServiceCertificateService {
  static const String _url =
      '${ApiConstants.baseUrl}medservice_pro.medservice.api.maintenance_visit.generate_certificates';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> generateCertificate({
    required String visitId,
    required File customerImageFile,
    bool autoSubmit = true,
  }) async {
    try {
      // 🔐 Get authentication from secure storage
      final apiKey = await _storage.read(key: 'api_key');
      final apiSecret = await _storage.read(key: 'api_secret');
      final sessionId = await _storage.read(key: 'session_id');

      if (apiKey == null && apiSecret == null && sessionId == null) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      // 📷 Convert image to base64 data URI
      String customerImageDataUri;

      if (await customerImageFile.exists()) {
        // Read file as bytes
        final bytes = await customerImageFile.readAsBytes();

        // Detect MIME type from file extension
        final extension = customerImageFile.path.split('.').last.toLowerCase();
        String mimeType = 'image/jpeg'; // default

        if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'jpg' || extension == 'jpeg') {
          mimeType = 'image/jpeg';
        } else if (extension == 'gif') {
          mimeType = 'image/gif';
        } else if (extension == 'webp') {
          mimeType = 'image/webp';
        }

        // Convert to base64
        final base64Image = base64Encode(bytes);

        // Create data URI (data:image/png;base64,...)
        customerImageDataUri = 'data:$mimeType;base64,$base64Image';
      } else {
        return {'success': false, 'message': 'Image file does not exist'};
      }

      // 🔐 SET AUTHENTICATION HEADERS
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (apiKey != null && apiSecret != null) {
        headers['Authorization'] = 'token $apiKey:$apiSecret';
      } else if (sessionId != null) {
        headers['Authorization'] = 'token $sessionId';
        headers['Cookie'] = 'sid=$sessionId';
      }

      // 🔹 BUILD JSON BODY
      final body = {
        "visit_id": visitId,
        "customer_image": customerImageDataUri,
        "auto_submit": autoSubmit,
      };

      final jsonBody = jsonEncode(body);

      // 🚀 SEND REQUEST
      final response = await http.post(
        Uri.parse(_url),
        headers: headers,
        body: jsonBody,
      );

      final responseBody = response.body;

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);

        // Check if the response indicates success or error
        if (decoded['message'] != null) {
          if (decoded['message'] is Map) {
            final msg = decoded['message'];

            if (msg['success'] == false) {
              // Backend returned an error
              final errorMsg =
                  msg['message'] ?? 'Certificate generation failed';
              final errorDetails = msg['error_details'];

              return {
                'success': false,
                'message': errorDetails != null
                    ? '$errorMsg: $errorDetails'
                    : errorMsg,
              };
            }
          }
        }

        return {'success': true, 'data': decoded};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
        };
      } else {
        try {
          final decoded = json.decode(responseBody);
          final errorMsg =
              decoded['message'] ??
              decoded['error'] ??
              decoded['exc'] ??
              'Certificate generation failed';
          return {'success': false, 'message': errorMsg};
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
