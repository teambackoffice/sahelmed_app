import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_msc_count_modal.dart';
import 'package:sahelmed_app/services/get_msc_count_service.dart';

class GetMachineServiceCertificateCountProvider extends ChangeNotifier {
  final GetMachineServiceCertificateCountService _service =
      GetMachineServiceCertificateCountService();

  bool isLoading = false;
  int totalCount = 0;
  String errorMessage = '';

  Future<void> fetchTotalCount() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final MachineServiceCertificateCountModel response = await _service
          .getTotalCount();

      totalCount = response.totalCount;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
