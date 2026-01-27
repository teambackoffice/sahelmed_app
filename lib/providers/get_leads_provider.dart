import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_leads_modal.dart';
import 'package:sahelmed_app/services/get_leads_service.dart';

class LeadController extends ChangeNotifier {
  final LeadService _leadService = LeadService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Lead> _leads = []; // Lead from get_leads_modal.dart
  int _totalCount = 0;
  bool _hasMore = false;
  Pagination? _pagination;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Lead> get leads => _leads;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  Pagination? get pagination => _pagination;

  Future<void> getLeads() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _leadService.fetchLeads();

      if (result.message.success) {
        _leads = result.message.leads; // Already List<Lead> from Message class
        _totalCount = result.message.totalCount;
        _hasMore = result.message.hasMore;
        _pagination = result.message.pagination;
      } else {
        _errorMessage = result.message.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load leads: ${e.toString()}';
      print('Error fetching leads: $e'); // For debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh leads
  Future<void> refreshLeads() async {
    await getLeads();
  }

  // Clear leads
  void clearLeads() {
    _leads = [];
    _errorMessage = null;
    _totalCount = 0;
    _hasMore = false;
    _pagination = null;
    notifyListeners();
  }
}
