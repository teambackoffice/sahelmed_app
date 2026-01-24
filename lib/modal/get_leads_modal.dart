// To parse this JSON data, do
//
//     final getLeadModal = getLeadModalFromJson(jsonString);

import 'dart:convert';

GetLeadModal getLeadModalFromJson(String str) =>
    GetLeadModal.fromJson(json.decode(str));

String getLeadModalToJson(GetLeadModal data) => json.encode(data.toJson());

class GetLeadModal {
  Message message;

  GetLeadModal({required this.message});

  factory GetLeadModal.fromJson(Map<String, dynamic> json) =>
      GetLeadModal(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  List<Lead> leads;
  int totalCount;
  int returnedCount;
  bool hasMore;
  Pagination pagination;

  Message({
    required this.success,
    required this.message,
    required this.leads,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
    required this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"],
    message: json["message"],
    leads: List<Lead>.from(json["leads"].map((x) => Lead.fromJson(x))),
    totalCount: json["total_count"],
    returnedCount: json["returned_count"],
    hasMore: json["has_more"],
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "leads": List<dynamic>.from(leads.map((x) => x.toJson())),
    "total_count": totalCount,
    "returned_count": returnedCount,
    "has_more": hasMore,
    "pagination": pagination.toJson(),
  };
}

class Lead {
  String id;
  String leadName;
  dynamic companyName;
  dynamic email;
  dynamic mobile;
  dynamic phone;
  String status;
  dynamic source;
  String leadOwner;
  dynamic territory;
  dynamic city;
  dynamic state;
  String country;
  dynamic industry;
  double annualRevenue;
  String noOfEmployees;
  String qualificationStatus;
  dynamic rating;
  DateTime createdOn;
  DateTime lastModified;
  String createdBy;
  String modifiedBy;

  Lead({
    required this.id,
    required this.leadName,
    required this.companyName,
    required this.email,
    required this.mobile,
    required this.phone,
    required this.status,
    required this.source,
    required this.leadOwner,
    required this.territory,
    required this.city,
    required this.state,
    required this.country,
    required this.industry,
    required this.annualRevenue,
    required this.noOfEmployees,
    required this.qualificationStatus,
    required this.rating,
    required this.createdOn,
    required this.lastModified,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
    id: json["id"],
    leadName: json["lead_name"],
    companyName: json["company_name"],
    email: json["email"],
    mobile: json["mobile"],
    phone: json["phone"],
    status: json["status"],
    source: json["source"],
    leadOwner: json["lead_owner"],
    territory: json["territory"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    industry: json["industry"],
    annualRevenue: json["annual_revenue"],
    noOfEmployees: json["no_of_employees"],
    qualificationStatus: json["qualification_status"],
    rating: json["rating"],
    createdOn: DateTime.parse(json["created_on"]),
    lastModified: DateTime.parse(json["last_modified"]),
    createdBy: json["created_by"],
    modifiedBy: json["modified_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_name": leadName,
    "company_name": companyName,
    "email": email,
    "mobile": mobile,
    "phone": phone,
    "status": status,
    "source": source,
    "lead_owner": leadOwner,
    "territory": territory,
    "city": city,
    "state": state,
    "country": country,
    "industry": industry,
    "annual_revenue": annualRevenue,
    "no_of_employees": noOfEmployees,
    "qualification_status": qualificationStatus,
    "rating": rating,
    "created_on": createdOn.toIso8601String(),
    "last_modified": lastModified.toIso8601String(),
    "created_by": createdBy,
    "modified_by": modifiedBy,
  };
}

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
