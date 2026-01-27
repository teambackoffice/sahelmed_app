import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_material_request_modal.dart';
import '../services/get_material_request_service.dart';

class GetMachineRequestController extends ChangeNotifier {
  final GetMachineRequestService _service = GetMachineRequestService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Datum> _requests = [];
  List<Datum> get requests => _requests;

  Pagination? _pagination;
  Pagination? get pagination => _pagination;

  int _currentPage = 1;

  Future<void> fetchRequests() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage = 1;
      _requests.clear();

      final response = await _service.fetchMaterialRequests();

      _requests.addAll(response.message.data);
      _pagination = response.message.pagination;

      if (_pagination?.hasNext == true) {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _requests.clear();
    _pagination = null;
    _currentPage = 1;
    notifyListeners();
  }
}
