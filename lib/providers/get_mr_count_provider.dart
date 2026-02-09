// material_request_provider.dart

import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_mr_count_modal.dart';
import 'package:sahelmed_app/services/get_mr_count_service.dart';

class GetMaterialRequestCountProvider extends ChangeNotifier {
  final GetMaterialRequestCountService _service =
      GetMaterialRequestCountService();

  MaterialRequestCountModel? materialRequestCount;
  bool isLoading = false;
  String? error;

  Future<void> fetchMaterialRequestCount() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      materialRequestCount = await _service.getMaterialRequestCount();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
