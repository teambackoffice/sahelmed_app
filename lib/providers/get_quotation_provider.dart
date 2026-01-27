import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_quotation_modal.dart';

import '../services/get_quotation_service.dart';

class GetQuotationController extends ChangeNotifier {
  final GetQuotationService _service = GetQuotationService();

  bool isLoading = false;
  String? errorMessage;
  List<Quotation> quotations = [];
  bool hasMore = false;
  int totalCount = 0;

  Future<void> fetchQuotations() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.getQuotations();

      final message = response.message;

      quotations = message.quotations;

      hasMore = message.hasMore;
      totalCount = message.totalCount;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    quotations.clear();
    hasMore = false;
    totalCount = 0;
    notifyListeners();
  }
}
