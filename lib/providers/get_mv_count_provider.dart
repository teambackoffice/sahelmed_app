import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_mv_count_modal.dart';

import '../services/get_mv_count_service.dart';

class GetMvCountProvider extends ChangeNotifier {
  final GetMvCountService _service = GetMvCountService();

  bool isLoading = false;
  String? errorMessage;

  GetMvCountModalClass? mvCountData;

  Future<void> fetchMvCount() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      mvCountData = await _service.getMvCount();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Optional helpers
  int get totalCount => mvCountData?.message.totalCount ?? 0;

  int get fullyCompleted =>
      mvCountData?.message.breakdown.byCompletionStatus.fullyCompleted ?? 0;

  int get partiallyCompleted =>
      mvCountData?.message.breakdown.byCompletionStatus.partiallyCompleted ?? 0;

  int get assigned =>
      mvCountData?.message.breakdown.byCustomVisitStatus.assigned ?? 0;

  int get completed =>
      mvCountData?.message.breakdown.byCustomVisitStatus.completed ?? 0;

  int get inProgress =>
      mvCountData?.message.breakdown.byCustomVisitStatus.inProgress ?? 0;

  int get open => mvCountData?.message.breakdown.byCustomVisitStatus.open ?? 0;
}
