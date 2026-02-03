import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/create_quotation_response.dart';
import '../services/create_quotation_service.dart';

class CreateQuotationController extends ChangeNotifier {
  final CreateQuotationService _service = CreateQuotationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  QuotationResponse? _quotationResponse;
  QuotationResponse? get quotationResponse => _quotationResponse;

  Future<void> createQuotation({
    required String quotationTo,
    required String partyName,
    required String validTill,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quotationResponse = await _service.createQuotation(
        quotationTo: quotationTo,
        partyName: partyName,
        validTill: validTill,
        items: items,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
