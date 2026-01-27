// To parse this JSON data, do
//
//     final getQuotationModalClass = getQuotationModalClassFromJson(jsonString);

import 'dart:convert';

GetQuotationModalClass getQuotationModalClassFromJson(String str) =>
    GetQuotationModalClass.fromJson(json.decode(str));

String getQuotationModalClassToJson(GetQuotationModalClass data) =>
    json.encode(data.toJson());

class GetQuotationModalClass {
  Message message;

  GetQuotationModalClass({required this.message});

  factory GetQuotationModalClass.fromJson(Map<String, dynamic> json) =>
      GetQuotationModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  List<Quotation> quotations;
  int totalCount;
  int returnedCount;
  bool hasMore;
  Pagination pagination;

  Message({
    required this.success,
    required this.message,
    required this.quotations,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
    required this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"],
    message: json["message"],
    quotations: List<Quotation>.from(
      json["quotations"].map((x) => Quotation.fromJson(x)),
    ),
    totalCount: json["total_count"],
    returnedCount: json["returned_count"],
    hasMore: json["has_more"],
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "quotations": List<dynamic>.from(quotations.map((x) => x.toJson())),
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

class Quotation {
  String id;
  String title;
  String customer;
  String customerName;
  DateTime date;
  DateTime validTill;
  String status;
  double amount;
  String currency;
  String quotationTo;
  String orderType;
  String company;
  dynamic territory;
  dynamic contactPerson;
  dynamic contactMobile;
  dynamic contactEmail;
  DateTime createdOn;
  DateTime lastModified;
  String createdBy;
  String modifiedBy;

  Quotation({
    required this.id,
    required this.title,
    required this.customer,
    required this.customerName,
    required this.date,
    required this.validTill,
    required this.status,
    required this.amount,
    required this.currency,
    required this.quotationTo,
    required this.orderType,
    required this.company,
    required this.territory,
    required this.contactPerson,
    required this.contactMobile,
    required this.contactEmail,
    required this.createdOn,
    required this.lastModified,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
    id: json["id"],
    title: json["title"],
    customer: json["customer"],
    customerName: json["customer_name"],
    date: DateTime.parse(json["date"]),
    validTill: DateTime.parse(json["valid_till"]),
    status: json["status"],
    amount: json["amount"]?.toDouble(),
    currency: json["currency"],
    quotationTo: json["quotation_to"],
    orderType: json["order_type"],
    company: json["company"],
    territory: json["territory"],
    contactPerson: json["contact_person"],
    contactMobile: json["contact_mobile"],
    contactEmail: json["contact_email"],
    createdOn: DateTime.parse(json["created_on"]),
    lastModified: DateTime.parse(json["last_modified"]),
    createdBy: json["created_by"],
    modifiedBy: json["modified_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "customer": customer,
    "customer_name": customerName,
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "valid_till":
        "${validTill.year.toString().padLeft(4, '0')}-${validTill.month.toString().padLeft(2, '0')}-${validTill.day.toString().padLeft(2, '0')}",
    "status": status,
    "amount": amount,
    "currency": currency,
    "quotation_to": quotationTo,
    "order_type": orderType,
    "company": company,
    "territory": territory,
    "contact_person": contactPerson,
    "contact_mobile": contactMobile,
    "contact_email": contactEmail,
    "created_on": createdOn.toIso8601String(),
    "last_modified": lastModified.toIso8601String(),
    "created_by": createdBy,
    "modified_by": modifiedBy,
  };
}
