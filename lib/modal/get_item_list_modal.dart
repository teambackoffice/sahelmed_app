import 'dart:convert';

ItemsResponse itemsResponseFromJson(String str) =>
    ItemsResponse.fromJson(json.decode(str));

class ItemsResponse {
  final bool success;
  final String message;
  final List<Item> items;
  final int totalCount;
  final int returnedCount;
  final bool hasMore;
  final Pagination pagination;

  ItemsResponse({
    required this.success,
    required this.message,
    required this.items,
    required this.totalCount,
    required this.returnedCount,
    required this.hasMore,
    required this.pagination,
  });

  factory ItemsResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message'];
    return ItemsResponse(
      success: msg['success'],
      message: msg['message'],
      items: List<Item>.from(msg['items'].map((x) => Item.fromJson(x))),
      totalCount: msg['total_count'],
      returnedCount: msg['returned_count'],
      hasMore: msg['has_more'],
      pagination: Pagination.fromJson(msg['pagination']),
    );
  }
}

class Item {
  final String id;
  final String itemCode;
  final String itemName;
  final String description;
  final String itemGroup;
  final String stockUom;
  final bool isStockItem;
  final bool isSalesItem;
  final bool isPurchaseItem;
  final bool disabled;
  final double valuationRate;
  final double lastPurchaseRate;
  final String? image;
  final String countryOfOrigin;

  Item({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.itemGroup,
    required this.stockUom,
    required this.isStockItem,
    required this.isSalesItem,
    required this.isPurchaseItem,
    required this.disabled,
    required this.valuationRate,
    required this.lastPurchaseRate,
    this.image,
    required this.countryOfOrigin,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    itemCode: json['item_code'],
    itemName: json['item_name'],
    description: json['description'],
    itemGroup: json['item_group'],
    stockUom: json['stock_uom'],
    isStockItem: json['is_stock_item'],
    isSalesItem: json['is_sales_item'],
    isPurchaseItem: json['is_purchase_item'],
    disabled: json['disabled'],
    valuationRate: (json['valuation_rate'] ?? 0).toDouble(),
    lastPurchaseRate: (json['last_purchase_rate'] ?? 0).toDouble(),
    image: json['image'],
    countryOfOrigin: json['country_of_origin'],
  );
}

class Pagination {
  final int start;
  final int limit;
  final int total;

  Pagination({required this.start, required this.limit, required this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    start: json['start'],
    limit: json['limit'],
    total: json['total'],
  );
}
