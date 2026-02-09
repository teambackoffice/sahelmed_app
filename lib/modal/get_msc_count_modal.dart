class MachineServiceCertificateCountModel {
  final bool success;
  final String message;
  final int totalCount;

  MachineServiceCertificateCountModel({
    required this.success,
    required this.message,
    required this.totalCount,
  });

  factory MachineServiceCertificateCountModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MachineServiceCertificateCountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalCount: json['total_count'] ?? 0,
    );
  }
}
