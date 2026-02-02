// To parse this JSON data, do
//
//     final getMachineServiceModalClass = getMachineServiceModalClassFromJson(jsonString);

import 'dart:convert';

GetMachineServiceModalClass getMachineServiceModalClassFromJson(String str) =>
    GetMachineServiceModalClass.fromJson(json.decode(str));

String getMachineServiceModalClassToJson(GetMachineServiceModalClass data) =>
    json.encode(data.toJson());

class GetMachineServiceModalClass {
  Message message;

  GetMachineServiceModalClass({required this.message});

  factory GetMachineServiceModalClass.fromJson(Map<String, dynamic> json) =>
      GetMachineServiceModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  List<Certificate> certificates;
  int totalCount;
  int returnedCount;
  bool hasMore;
  Pagination pagination;

  Message({
    required this.success,
    required this.message,
    required this.certificates,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
    required this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"],
    message: json["message"],
    certificates: List<Certificate>.from(
      json["certificates"].map((x) => Certificate.fromJson(x)),
    ),
    totalCount: json["total_count"],
    returnedCount: json["returned_count"],
    hasMore: json["has_more"],
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "certificates": List<dynamic>.from(certificates.map((x) => x.toJson())),
    "total_count": totalCount,
    "returned_count": returnedCount,
    "has_more": hasMore,
    "pagination": pagination.toJson(),
  };
}

class Certificate {
  String id;
  String title;
  String customer;
  String? customerName;
  dynamic customerAddress;
  DateTime? visitDate;
  String visitTime;
  String serviceEngineer;
  String serviceEngineerName;
  String? maintenanceVisit;
  String certificateNumber;
  ContractType contractType;
  DateTime certificateIssueDate;
  String? serviceDescription;
  OverallServiceStatus overallServiceStatus;
  int totalMachinesServiced;
  int machinesPassed;
  int machinesFailed;
  dynamic technicianComments;
  DateTime? serviceDate;
  DateTime? nextServiceDue;
  int certificateGenerated;
  Status status;
  DateTime createdOn;
  DateTime lastModified;
  EdBy? createdBy;
  EdBy? modifiedBy;

  Certificate({
    required this.id,
    required this.title,
    required this.customer,
    required this.customerName,
    required this.customerAddress,
    required this.visitDate,
    required this.visitTime,
    required this.serviceEngineer,
    required this.serviceEngineerName,
    required this.maintenanceVisit,
    required this.certificateNumber,
    required this.contractType,
    required this.certificateIssueDate,
    required this.serviceDescription,
    required this.overallServiceStatus,
    required this.totalMachinesServiced,
    required this.machinesPassed,
    required this.machinesFailed,
    required this.technicianComments,
    required this.serviceDate,
    required this.nextServiceDue,
    required this.certificateGenerated,
    required this.status,
    required this.createdOn,
    required this.lastModified,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: json["id"],
    title: json["title"],
    customer: json["customer"],
    customerName: json["customer_name"],
    customerAddress: json["customer_address"],
    visitDate: json["visit_date"] == null
        ? null
        : DateTime.parse(json["visit_date"]),
    visitTime: json["visit_time"] ?? "",
    serviceEngineer: json["service_engineer"] ?? "",
    serviceEngineerName: json["service_engineer_name"] ?? "",
    maintenanceVisit: json["maintenance_visit"],
    certificateNumber: json["certificate_number"] ?? "",
    contractType:
        contractTypeValues.map[json["contract_type"]] ?? ContractType.EMPTY,
    certificateIssueDate: DateTime.parse(json["certificate_issue_date"]),
    serviceDescription: json["service_description"],
    overallServiceStatus:
        overallServiceStatusValues.map[json["overall_service_status"]] ??
        OverallServiceStatus.PASS,
    totalMachinesServiced: json["total_machines_serviced"] ?? 0,
    machinesPassed: json["machines_passed"] ?? 0,
    machinesFailed: json["machines_failed"] ?? 0,
    technicianComments: json["technician_comments"],
    serviceDate: json["service_date"] == null
        ? null
        : DateTime.parse(json["service_date"]),
    nextServiceDue: json["next_service_due"] == null
        ? null
        : DateTime.parse(json["next_service_due"]),
    certificateGenerated: json["certificate_generated"] ?? 0,
    status: statusValues.map[json["status"]] ?? Status.DRAFT,
    createdOn: DateTime.parse(json["created_on"]),
    lastModified: DateTime.parse(json["last_modified"]),
    createdBy: json["created_by"] != null
        ? edByValues.map[json["created_by"]]
        : null,
    modifiedBy: json["modified_by"] != null
        ? edByValues.map[json["modified_by"]]
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "customer": customer,
    "customer_name": customerName,
    "customer_address": customerAddress,
    "visit_date":
        "${visitDate!.year.toString().padLeft(4, '0')}-${visitDate!.month.toString().padLeft(2, '0')}-${visitDate!.day.toString().padLeft(2, '0')}",
    "visit_time": visitTime,
    "service_engineer": serviceEngineer,
    "service_engineer_name": serviceEngineerName,
    "maintenance_visit": maintenanceVisit,
    "certificate_number": certificateNumber,
    "contract_type": contractTypeValues.reverse[contractType],
    "certificate_issue_date":
        "${certificateIssueDate.year.toString().padLeft(4, '0')}-${certificateIssueDate.month.toString().padLeft(2, '0')}-${certificateIssueDate.day.toString().padLeft(2, '0')}",
    "service_description": serviceDescription,
    "overall_service_status":
        overallServiceStatusValues.reverse[overallServiceStatus],
    "total_machines_serviced": totalMachinesServiced,
    "machines_passed": machinesPassed,
    "machines_failed": machinesFailed,
    "technician_comments": technicianComments,
    "service_date":
        "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    "next_service_due":
        "${nextServiceDue!.year.toString().padLeft(4, '0')}-${nextServiceDue!.month.toString().padLeft(2, '0')}-${nextServiceDue!.day.toString().padLeft(2, '0')}",
    "certificate_generated": certificateGenerated,
    "status": statusValues.reverse[status],
    "created_on": createdOn.toIso8601String(),
    "last_modified": lastModified.toIso8601String(),
    "created_by": createdBy != null ? edByValues.reverse[createdBy] : null,
    "modified_by": modifiedBy != null ? edByValues.reverse[modifiedBy] : null,
  };
}

enum ContractType { EMERGENCY, EMPTY, PPM }

final contractTypeValues = EnumValues({
  "Emergency": ContractType.EMERGENCY,
  "": ContractType.EMPTY,
  "PPM": ContractType.PPM,
});

enum EdBy { ADMINISTRATOR, SALESENGINEER_GMAIL_COM, SERVICEMANAGER_GMAIL_COM }

final edByValues = EnumValues({
  "Administrator": EdBy.ADMINISTRATOR,
  "salesengineer@gmail.com": EdBy.SALESENGINEER_GMAIL_COM,
  "servicemanager@gmail.com": EdBy.SERVICEMANAGER_GMAIL_COM,
});

enum OverallServiceStatus { PASS }

final overallServiceStatusValues = EnumValues({
  "Pass": OverallServiceStatus.PASS,
});

enum Status { DRAFT, SUBMITTED }

final statusValues = EnumValues({
  "Draft": Status.DRAFT,
  "Submitted": Status.SUBMITTED,
});

class Pagination {
  int start;
  int limit;
  int total;

  Pagination({required this.start, required this.limit, required this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    start: json["start"],
    limit: json["limit"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "start": start,
    "limit": limit,
    "total": total,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
