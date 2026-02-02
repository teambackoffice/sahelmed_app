import 'package:flutter/material.dart';
import 'package:sahelmed_app/services/create_mr_service.dart';

class CreateMaterialRequestProvider extends ChangeNotifier {
  final CreateMaterialRequestService _service = CreateMaterialRequestService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? responseData;

  Future<void> createMaterialRequest({
    required String materialRequestType,
    required String company,
    required String setWarehouse,
    required String requiredByDate,
    required List<Map<String, dynamic>> items,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      responseData = await _service.createMaterialRequest(
        materialRequestType: materialRequestType,
        company: company,
        setWarehouse: setWarehouse,
        scheduleDate: requiredByDate,
        items: items,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
