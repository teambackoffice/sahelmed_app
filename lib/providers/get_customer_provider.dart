import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_customer_modal.dart';
import 'package:sahelmed_app/services/get_customer_service.dart';

class GetCustomerProvider extends ChangeNotifier {
  final GetCustomerService _customerService = GetCustomerService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Customer> _customers = [];
  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _customerService.fetchCustomers();
      _customers = response.message.customers;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
