import 'dart:convert';

CustomerResponse customerResponseFromJson(String str) =>
    CustomerResponse.fromJson(json.decode(str));

class CustomerResponse {
  final Message message;

  CustomerResponse({required this.message});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(message: Message.fromJson(json['message']));
  }
}

class Message {
  final bool success;
  final String message;
  final List<Customer> customers;
  final int totalCount;
  final int returnedCount;
  final bool hasMore;

  Message({
    required this.success,
    required this.message,
    required this.customers,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      success: json['success'],
      message: json['message'],
      customers: List<Customer>.from(
        json['customers'].map((x) => Customer.fromJson(x)),
      ),
      totalCount: json['total_count'],
      returnedCount: json['returned_count'],
      hasMore: json['has_more'],
    );
  }
}

class Customer {
  final String id;
  final String customerName;
  final String customerType;
  final String? customerGroup;
  final String? industry;
  final String? marketSegment;
  final String? defaultCurrency;
  final bool disabled;
  final bool isFrozen;
  final String createdOn;

  Customer({
    required this.id,
    required this.customerName,
    required this.customerType,
    this.customerGroup,
    this.industry,
    this.marketSegment,
    this.defaultCurrency,
    required this.disabled,
    required this.isFrozen,
    required this.createdOn,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerName: json['customer_name'],
      customerType: json['customer_type'],
      customerGroup: json['customer_group'],
      industry: json['industry'],
      marketSegment: json['market_segment'],
      defaultCurrency: json['default_currency'],
      disabled: json['disabled'],
      isFrozen: json['is_frozen'],
      createdOn: json['created_on'],
    );
  }
}
