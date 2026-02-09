// material_request_count_model.dart

class MaterialRequestCountModel {
  final bool success;
  final String message;
  final int totalCount;

  MaterialRequestCountModel({
    required this.success,
    required this.message,
    required this.totalCount,
  });

  factory MaterialRequestCountModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestCountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalCount: json['total_count'] ?? 0,
    );
  }
}
