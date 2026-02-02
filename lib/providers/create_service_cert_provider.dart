import 'package:flutter/material.dart';
import 'dart:io';
import '../services/create_service_cert_service.dart';

class CreateMachineServiceCertificateController extends ChangeNotifier {
  final CreateMachineServiceCertificateService _service =
      CreateMachineServiceCertificateService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? certificateResponse;

  Future<void> generateCertificate({
    required String visitId,
    required File customerImageFile,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _service.generateCertificate(
      visitId: visitId,
      customerImageFile: customerImageFile,
    );

    isLoading = false;

    if (result['success'] == true) {
      certificateResponse = result['data'];
    } else {
      errorMessage = result['message'];
    }

    notifyListeners();
  }
}
