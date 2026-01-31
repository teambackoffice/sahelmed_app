// To parse this JSON data, do
//
//     final getWareHouseModalClass = getWareHouseModalClassFromJson(jsonString);

import 'dart:convert';

GetWareHouseModalClass getWareHouseModalClassFromJson(String str) =>
    GetWareHouseModalClass.fromJson(json.decode(str));

String getWareHouseModalClassToJson(GetWareHouseModalClass data) =>
    json.encode(data.toJson());

class GetWareHouseModalClass {
  Message message;

  GetWareHouseModalClass({required this.message});

  factory GetWareHouseModalClass.fromJson(Map<String, dynamic> json) =>
      GetWareHouseModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  List<Warehouse> warehouses;
  int totalCount;
  int returnedCount;
  bool hasMore;
  Pagination pagination;

  Message({
    required this.success,
    required this.message,
    required this.warehouses,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
    required this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"],
    message: json["message"],
    warehouses: List<Warehouse>.from(
      json["warehouses"].map((x) => Warehouse.fromJson(x)),
    ),
    totalCount: json["total_count"],
    returnedCount: json["returned_count"],
    hasMore: json["has_more"],
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "warehouses": List<dynamic>.from(warehouses.map((x) => x.toJson())),
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

class Warehouse {
  String id;
  String warehouseName;
  String company;
  bool isGroup;
  String? parentWarehouse;
  bool disabled;
  String? warehouseType;
  dynamic email;
  dynamic phone;
  dynamic mobile;
  dynamic addressLine1;
  dynamic addressLine2;
  dynamic city;
  dynamic state;
  dynamic pin;
  dynamic country;

  Warehouse({
    required this.id,
    required this.warehouseName,
    required this.company,
    required this.isGroup,
    required this.parentWarehouse,
    required this.disabled,
    required this.warehouseType,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pin,
    required this.country,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
    id: json["id"],
    warehouseName: json["warehouse_name"],
    company: json["company"],
    isGroup: json["is_group"],
    parentWarehouse: json["parent_warehouse"],
    disabled: json["disabled"],
    warehouseType: json["warehouse_type"],
    email: json["email"],
    phone: json["phone"],
    mobile: json["mobile"],
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    city: json["city"],
    state: json["state"],
    pin: json["pin"],
    country: json["country"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "warehouse_name": warehouseName,
    "company": company,
    "is_group": isGroup,
    "parent_warehouse": parentWarehouse,
    "disabled": disabled,
    "warehouse_type": warehouseType,
    "email": email,
    "phone": phone,
    "mobile": mobile,
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "pin": pin,
    "country": country,
  };
}
