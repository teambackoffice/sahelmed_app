import 'package:flutter/material.dart';
import '../services/create_lead_service.dart';

class CreateLeadProvider extends ChangeNotifier {
  final CreateLeadService _leadService = CreateLeadService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _response;
  Map<String, dynamic>? get response => _response;

  Future<void> createLead({
    required String leadName,
    required String companyName,
    required String email,
    required String mobileNo,
    required String source,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _response = await _leadService.createLead(
        leadName: leadName,
        companyName: companyName,
        email: email,
        mobileNo: mobileNo,
        source: source,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
