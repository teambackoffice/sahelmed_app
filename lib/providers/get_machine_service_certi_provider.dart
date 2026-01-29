import 'package:flutter/material.dart';
import 'package:sahelmed_app/modal/get_machine_service_modal.dart';
import 'package:sahelmed_app/services/get_machine_service_certi_service.dart';

class GetMachineServiceProvider extends ChangeNotifier {
  final GetMachineServiceService _service = GetMachineServiceService();

  bool isLoading = false;
  String? errorMessage;

  GetMachineServiceModalClass? machineServiceResponse;

  List<Certificate> get certificates =>
      machineServiceResponse?.message.certificates ?? [];

  Future<void> fetchMachineServiceCertificates() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      machineServiceResponse = await _service.fetchMachineServiceCertificates();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
