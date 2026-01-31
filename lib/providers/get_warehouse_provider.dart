import 'package:flutter/material.dart';

import '../modal/get_warehouse_modal.dart';
import '../services/get_warehouse_service.dart';

class GetWarehouseProvider extends ChangeNotifier {
  final GetWarehouseService _service = GetWarehouseService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Warehouse> _warehouses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Warehouse> get warehouses => _warehouses;

  Future<void> fetchWarehouses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getWarehouses();

      _warehouses = response.message.warehouses;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: clear data
  void clear() {
    _warehouses = [];
    _errorMessage = null;
    notifyListeners();
  }
}
