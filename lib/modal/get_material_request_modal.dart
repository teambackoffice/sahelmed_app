// To parse this JSON data, do
//
//     final getMachineRequestModalClass = getMachineRequestModalClassFromJson(jsonString);

import 'dart:convert';

GetMaterialRequestModalClass getMaterialRequestModalClassFromJson(String str) =>
    GetMaterialRequestModalClass.fromJson(json.decode(str));

String getMaterialRequestModalClassToJson(GetMaterialRequestModalClass data) =>
    json.encode(data.toJson());

class GetMaterialRequestModalClass {
  Message message;

  GetMaterialRequestModalClass({required this.message});

  factory GetMaterialRequestModalClass.fromJson(Map<String, dynamic> json) =>
      GetMaterialRequestModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  List<Datum> data;
  Pagination pagination;

  Message({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Datum {
  String name;
  String title;
  String materialRequestType;
  String status;
  DateTime transactionDate;
  DateTime scheduleDate;
  String company;
  dynamic setFromWarehouse;
  dynamic setWarehouse;
  dynamic customer;
  String owner;
  DateTime creation;
  DateTime modified;
  String modifiedBy;

  Datum({
    required this.name,
    required this.title,
    required this.materialRequestType,
    required this.status,
    required this.transactionDate,
    required this.scheduleDate,
    required this.company,
    required this.setFromWarehouse,
    required this.setWarehouse,
    required this.customer,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json["name"],
    title: json["title"],
    materialRequestType: json["material_request_type"],
    status: json["status"],
    transactionDate: DateTime.parse(json["transaction_date"]),
    scheduleDate: DateTime.parse(json["schedule_date"]),
    company: json["company"],
    setFromWarehouse: json["set_from_warehouse"],
    setWarehouse: json["set_warehouse"],
    customer: json["customer"],
    owner: json["owner"],
    creation: DateTime.parse(json["creation"]),
    modified: DateTime.parse(json["modified"]),
    modifiedBy: json["modified_by"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "title": title,
    "material_request_type": materialRequestType,
    "status": status,
    "transaction_date":
        "${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}",
    "schedule_date":
        "${scheduleDate.year.toString().padLeft(4, '0')}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}",
    "company": company,
    "set_from_warehouse": setFromWarehouse,
    "set_warehouse": setWarehouse,
    "customer": customer,
    "owner": owner,
    "creation": creation.toIso8601String(),
    "modified": modified.toIso8601String(),
    "modified_by": modifiedBy,
  };
}

class Pagination {
  int currentPage;
  int pageSize;
  int totalCount;
  int totalPages;
  bool hasNext;
  bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    pageSize: json["page_size"],
    totalCount: json["total_count"],
    totalPages: json["total_pages"],
    hasNext: json["has_next"],
    hasPrev: json["has_prev"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "page_size": pageSize,
    "total_count": totalCount,
    "total_pages": totalPages,
    "has_next": hasNext,
    "has_prev": hasPrev,
  };
}
