import 'dart:convert';

GetQuotationModalClass getQuotationModalClassFromJson(String str) =>
    GetQuotationModalClass.fromJson(json.decode(str));

String getQuotationModalClassToJson(GetQuotationModalClass data) =>
    json.encode(data.toJson());

class GetQuotationModalClass {
  final Message message;

  GetQuotationModalClass({required this.message});

  factory GetQuotationModalClass.fromJson(Map<String, dynamic> json) =>
      GetQuotationModalClass(message: Message.fromJson(json['message']));

  Map<String, dynamic> toJson() => {'message': message.toJson()};
}

class Message {
  final bool success;
  final String message;
  final List<Quotation> quotations;
  final int totalCount;
  final int returnedCount;
  final bool hasMore;
  final Pagination pagination;

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
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    quotations: (json['quotations'] as List<dynamic>? ?? [])
        .map((e) => Quotation.fromJson(e))
        .toList(),
    totalCount: json['total_count'] ?? 0,
    returnedCount: json['returned_count'] ?? 0,
    hasMore: json['has_more'] ?? false,
    pagination: Pagination.fromJson(json['pagination'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'quotations': quotations.map((e) => e.toJson()).toList(),
    'total_count': totalCount,
    'returned_count': returnedCount,
    'has_more': hasMore,
    'pagination': pagination.toJson(),
  };
}

class Pagination {
  final int start;
  final int limit;
  final int total;

  Pagination({required this.start, required this.limit, required this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    start: json['start'] ?? 0,
    limit: json['limit'] ?? 0,
    total: json['total'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'start': start,
    'limit': limit,
    'total': total,
  };
}

class Quotation {
  final String id;
  final String title;
  final String customer;
  final String customerName;
  final DateTime date;
  final DateTime? validTill;
  final String status;
  final double amount;
  final String currency;
  final String quotationTo;
  final String orderType;
  final String company;
  final String? territory;
  final String? contactPerson;
  final String? contactMobile;
  final String? contactEmail;
  final DateTime createdOn;
  final DateTime lastModified;
  final String createdBy;
  final String modifiedBy;

  Quotation({
    required this.id,
    required this.title,
    required this.customer,
    required this.customerName,
    required this.date,
    this.validTill,
    required this.status,
    required this.amount,
    required this.currency,
    required this.quotationTo,
    required this.orderType,
    required this.company,
    this.territory,
    this.contactPerson,
    this.contactMobile,
    this.contactEmail,
    required this.createdOn,
    required this.lastModified,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    customer: json['customer'] ?? '',
    customerName: json['customer_name'] ?? '',
    date: DateTime.parse(json['date']),
    validTill: json['valid_till'] != null
        ? DateTime.parse(json['valid_till'])
        : null,
    status: json['status'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] ?? '',
    quotationTo: json['quotation_to'] ?? '',
    orderType: json['order_type'] ?? '',
    company: json['company'] ?? '',
    territory: json['territory'],
    contactPerson: json['contact_person'],
    contactMobile: json['contact_mobile'],
    contactEmail: json['contact_email'],
    createdOn: DateTime.parse(json['created_on']),
    lastModified: DateTime.parse(json['last_modified']),
    createdBy: json['created_by'] ?? '',
    modifiedBy: json['modified_by'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'customer': customer,
    'customer_name': customerName,
    'date':
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'valid_till': validTill == null
        ? null
        : '${validTill!.year.toString().padLeft(4, '0')}-${validTill!.month.toString().padLeft(2, '0')}-${validTill!.day.toString().padLeft(2, '0')}',
    'status': status,
    'amount': amount,
    'currency': currency,
    'quotation_to': quotationTo,
    'order_type': orderType,
    'company': company,
    'territory': territory,
    'contact_person': contactPerson,
    'contact_mobile': contactMobile,
    'contact_email': contactEmail,
    'created_on': createdOn.toIso8601String(),
    'last_modified': lastModified.toIso8601String(),
    'created_by': createdBy,
    'modified_by': modifiedBy,
  };
}
