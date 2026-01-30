import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_mv_modal.dart';
import 'package:sahelmed_app/services/get_mv_services.dart';

class GetMaintenanceRequestController extends ChangeNotifier {
  final GetMaintenanceVisitService _service = GetMaintenanceVisitService();

  bool isLoading = false;
  String? errorMessage;

  List<Visit> visits = [];
  int totalCount = 0;

  Future<void> fetchMaintenanceRequests() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getMaintenanceRequests();

      visits = response.message.visits;
      totalCount = response.message.totalCount;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
