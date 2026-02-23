// To parse this JSON data, do
//
//     final itemsResponse = itemsResponseFromJson(jsonString);

import 'dart:convert';

ItemsResponse itemsResponseFromJson(String str) =>
    ItemsResponse.fromJson(json.decode(str));

String itemsResponseToJson(ItemsResponse data) => json.encode(data.toJson());

class ItemsResponse {
  Message message;

  ItemsResponse({required this.message});

  factory ItemsResponse.fromJson(Map<String, dynamic> json) =>
      ItemsResponse(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  bool success;
  String message;
  List<Item> items;
  int? totalCount;
  int? returnedCount;
  bool? hasMore;
  Pagination? pagination;

  Message({
    required this.success,
    required this.message,
    required this.items,
    this.totalCount,
    this.returnedCount,
    this.hasMore,
    this.pagination,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"],
    message: json["message"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    totalCount: json["total_count"],
    returnedCount: json["returned_count"],
    hasMore: json["has_more"],
    pagination: json["pagination"] != null
        ? Pagination.fromJson(json["pagination"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    if (totalCount != null) "total_count": totalCount,
    if (returnedCount != null) "returned_count": returnedCount,
    if (hasMore != null) "has_more": hasMore,
    if (pagination != null) "pagination": pagination!.toJson(),
  };
}

class Item {
  String id;
  String itemCode;
  String itemName;
  String? description;
  String? itemGroup;
  dynamic brand;
  String? stockUom;
  bool isStockItem;
  bool isSalesItem;
  bool isPurchaseItem;
  bool isServiceItem;
  bool disabled;
  double standardRate;
  double valuationRate;
  double lastPurchaseRate;
  String? image;
  double weightPerUnit;
  dynamic weightUom;
  String? countryOfOrigin;
  dynamic customsTariffNumber;
  List<Price> prices;
  DateTime createdOn;
  DateTime lastModified;
  String? createdBy;
  String? modifiedBy;

  Item({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.itemGroup,
    required this.brand,
    required this.stockUom,
    required this.isStockItem,
    required this.isSalesItem,
    required this.isPurchaseItem,
    required this.isServiceItem,
    required this.disabled,
    required this.standardRate,
    required this.valuationRate,
    required this.lastPurchaseRate,
    required this.image,
    required this.weightPerUnit,
    required this.weightUom,
    required this.countryOfOrigin,
    required this.customsTariffNumber,
    required this.prices,
    required this.createdOn,
    required this.lastModified,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? '',
    itemCode: json["item_code"] ?? '',
    itemName: json["item_name"] ?? '',
    description: json["description"],
    itemGroup: json["item_group"],
    brand: json["brand"],
    stockUom: json["stock_uom"],
    isStockItem: json["is_stock_item"] ?? false,
    isSalesItem: json["is_sales_item"] ?? false,
    isPurchaseItem: json["is_purchase_item"] ?? false,
    isServiceItem: json["is_service_item"] ?? false,
    disabled: json["disabled"] ?? false,
    standardRate: (json["standard_rate"] ?? 0).toDouble(),
    valuationRate: (json["valuation_rate"] ?? 0).toDouble(),
    lastPurchaseRate: (json["last_purchase_rate"] ?? 0).toDouble(),
    image: json["image"],
    weightPerUnit: (json["weight_per_unit"] ?? 0).toDouble(),
    weightUom: json["weight_uom"],
    countryOfOrigin: json["country_of_origin"],
    customsTariffNumber: json["customs_tariff_number"],
    prices: json["prices"] != null
        ? List<Price>.from(json["prices"].map((x) => Price.fromJson(x)))
        : [],
    createdOn: DateTime.parse(json["created_on"]),
    lastModified: DateTime.parse(json["last_modified"]),
    createdBy: json["created_by"],
    modifiedBy: json["modified_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_code": itemCode,
    "item_name": itemName,
    "description": description,
    "item_group": itemGroup,
    "brand": brand,
    "stock_uom": stockUom,
    "is_stock_item": isStockItem,
    "is_sales_item": isSalesItem,
    "is_purchase_item": isPurchaseItem,
    "is_service_item": isServiceItem,
    "disabled": disabled,
    "standard_rate": standardRate,
    "valuation_rate": valuationRate,
    "last_purchase_rate": lastPurchaseRate,
    "image": image,
    "weight_per_unit": weightPerUnit,
    "weight_uom": weightUom,
    "country_of_origin": countryOfOrigin,
    "customs_tariff_number": customsTariffNumber,
    "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
    "created_on": createdOn.toIso8601String(),
    "last_modified": lastModified.toIso8601String(),
    "created_by": createdBy,
    "modified_by": modifiedBy,
  };
}

class Price {
  String priceList;
  double rate;
  String currency;
  DateTime validFrom;
  dynamic validUpto;

  Price({
    required this.priceList,
    required this.rate,
    required this.currency,
    required this.validFrom,
    required this.validUpto,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    priceList: json["price_list"],
    rate: (json["rate"] ?? 0).toDouble(),
    currency: json["currency"],
    validFrom: DateTime.parse(json["valid_from"]),
    validUpto: json["valid_upto"],
  );

  Map<String, dynamic> toJson() => {
    "price_list": priceList,
    "rate": rate,
    "currency": currency,
    "valid_from":
        "${validFrom.year.toString().padLeft(4, '0')}-${validFrom.month.toString().padLeft(2, '0')}-${validFrom.day.toString().padLeft(2, '0')}",
    "valid_upto": validUpto,
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
