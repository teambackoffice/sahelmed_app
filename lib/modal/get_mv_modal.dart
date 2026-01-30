import 'dart:convert';

GetMaintenenceVisitModalClass getMaintenenceVisitModalClassFromJson(
  String str,
) => GetMaintenenceVisitModalClass.fromJson(json.decode(str));

String getMaintenenceVisitModalClassToJson(
  GetMaintenenceVisitModalClass data,
) => json.encode(data.toJson());

class GetMaintenenceVisitModalClass {
  Message message;

  GetMaintenenceVisitModalClass({required this.message});

  factory GetMaintenenceVisitModalClass.fromJson(Map<String, dynamic> json) =>
      GetMaintenenceVisitModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  List<Visit> visits;
  int totalCount;
  int returnedCount;
  bool hasMore;
  Pagination pagination;

  Message({
    required this.success,
    required this.message,
    required this.visits,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
    required this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    visits: json["visits"] != null
        ? List<Visit>.from(json["visits"].map((x) => Visit.fromJson(x)))
        : [],
    totalCount: json["total_count"] ?? 0,
    returnedCount: json["returned_count"] ?? 0,
    hasMore: json["has_more"] ?? false,
    pagination: json["pagination"] != null
        ? Pagination.fromJson(json["pagination"])
        : Pagination(start: 0, limit: 0, total: 0),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "visits": List<dynamic>.from(visits.map((x) => x.toJson())),
    "total_count": totalCount,
    "returned_count": returnedCount,
    "has_more": hasMore,
    "pagination": pagination.toJson(),
  };
}

class Pagination {
  int start;
  int limit;
  int total;

  Pagination({required this.start, required this.limit, required this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    start: json["start"] ?? 0,
    limit: json["limit"] ?? 0,
    total: json["total"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "start": start,
    "limit": limit,
    "total": total,
  };
}

class Visit {
  String id;
  String? maintenanceSchedule;
  String customer;
  String customerName;
  String? assignedEngineer;
  DateTime mntcDate;
  String mntcTime;
  String completionStatus; // Changed to String to handle any value
  String customVisitStatus; // Changed to String to handle any value
  String company; // Changed to String
  dynamic customerAddress;
  dynamic contactPerson;
  dynamic amendedFrom;
  List<Purpose> purposes;
  DateTime createdOn;
  DateTime lastModified;
  String createdBy; // Changed to String
  String modifiedBy; // Changed to String

  Visit({
    required this.id,
    this.maintenanceSchedule,
    required this.customer,
    required this.customerName,
    this.assignedEngineer,
    required this.mntcDate,
    required this.mntcTime,
    required this.completionStatus,
    required this.customVisitStatus,
    required this.company,
    this.customerAddress,
    this.contactPerson,
    this.amendedFrom,
    required this.purposes,
    required this.createdOn,
    required this.lastModified,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    try {
      return Visit(
        id: json["id"] ?? "",
        maintenanceSchedule: json["maintenance_schedule"],
        customer: json["customer"] ?? "",
        customerName: json["customer_name"] ?? "",
        assignedEngineer: json["assigned_engineer"],
        mntcDate: json["mntc_date"] != null
            ? DateTime.parse(json["mntc_date"])
            : DateTime.now(),
        mntcTime: json["mntc_time"] ?? "",
        completionStatus: json["completion_status"] ?? "Unknown",
        customVisitStatus: json["custom_visit_status"] ?? "Open",
        company: json["company"] ?? "",
        customerAddress: json["customer_address"],
        contactPerson: json["contact_person"],
        amendedFrom: json["amended_from"],
        purposes: json["purposes"] != null
            ? List<Purpose>.from(
                json["purposes"].map((x) => Purpose.fromJson(x)),
              )
            : [],
        createdOn: json["creation"] != null
            ? DateTime.parse(json["creation"])
            : DateTime.now(),
        lastModified: json["modified"] != null
            ? DateTime.parse(json["modified"])
            : DateTime.now(),
        createdBy: json["owner"] ?? "",
        modifiedBy: json["modified_by"] ?? "",
      );
    } catch (e) {
      print('Error parsing Visit: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "maintenance_schedule": maintenanceSchedule,
    "customer": customer,
    "customer_name": customerName,
    "assigned_engineer": assignedEngineer,
    "mntc_date":
        "${mntcDate.year.toString().padLeft(4, '0')}-${mntcDate.month.toString().padLeft(2, '0')}-${mntcDate.day.toString().padLeft(2, '0')}",
    "mntc_time": mntcTime,
    "completion_status": completionStatus,
    "custom_visit_status": customVisitStatus,
    "company": company,
    "customer_address": customerAddress,
    "contact_person": contactPerson,
    "amended_from": amendedFrom,
    "purposes": List<dynamic>.from(purposes.map((x) => x.toJson())),
    "creation": createdOn.toIso8601String(),
    "modified": lastModified.toIso8601String(),
    "owner": createdBy,
    "modified_by": modifiedBy,
  };
}

class Purpose {
  String itemCode;
  String itemName;
  String? serialNo;
  String description;
  String workDone;
  String? servicePerson;
  dynamic softwareEngineer;

  Purpose({
    required this.itemCode,
    required this.itemName,
    this.serialNo,
    required this.description,
    required this.workDone,
    this.servicePerson,
    this.softwareEngineer,
  });

  factory Purpose.fromJson(Map<String, dynamic> json) {
    try {
      return Purpose(
        itemCode: json["item_code"] ?? "",
        itemName: json["item_name"] ?? "",
        serialNo: json["serial_no"],
        description: json["description"] ?? "",
        workDone: json["work_done"] ?? "",
        servicePerson: json["service_person"],
        softwareEngineer: json["software_engineer"],
      );
    } catch (e) {
      print('Error parsing Purpose: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "item_name": itemName,
    "serial_no": serialNo,
    "description": description,
    "work_done": workDone,
    "service_person": servicePerson,
    "software_engineer": softwareEngineer,
  };
}
