import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_item_list_modal.dart';
import 'package:sahelmed_app/services/get_item_list_service.dart';

class ItemsProvider extends ChangeNotifier {
  final GetItemsService _service = GetItemsService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Item> _items = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Item> get items => _items;

  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchItems();
      _items = response.message.items;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
