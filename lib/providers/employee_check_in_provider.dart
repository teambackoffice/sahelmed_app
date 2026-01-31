import 'package:flutter/material.dart';
import 'package:sahelmed_app/services/employee_check_in_service.dart';

class EmployeeCheckinController extends ChangeNotifier {
  final EmployeeCheckinService _service = EmployeeCheckinService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? responseData;

  Future<void> checkIn({
    required String token,
    required String employee,
    required String time,
    required String latitude,
    required String longitude,
  }) async {
    await _handleRequest(
      type: CheckType.checkIn,
      token: token,
      employee: employee,
      time: time,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> checkOut({
    required String token,
    required String employee,
    required String time,
    required String latitude,
    required String longitude,
  }) async {
    await _handleRequest(
      type: CheckType.checkOut,
      token: token,
      employee: employee,
      time: time,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> _handleRequest({
    required CheckType type,
    required String token,
    required String employee,
    required String time,
    required String latitude,
    required String longitude,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      responseData = await _service.submitCheck(
        type: type,
        token: token,
        employee: employee,
        time: time,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
