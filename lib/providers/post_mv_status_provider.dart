import 'package:flutter/material.dart';
import 'package:sahelmed_app/services/mv_status_post_service.dart';

class UpdateVisitStatusController extends ChangeNotifier {
  final UpdateVisitStatusService _service = UpdateVisitStatusService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? responseData;

  Future<void> updateVisitStatus({
    required String visitId,
    required String visitStatus,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      responseData = await _service.updateVisitStatus(
        visitId: visitId,
        visitStatus: visitStatus,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
