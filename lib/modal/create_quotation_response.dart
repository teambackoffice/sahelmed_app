import 'dart:convert';

QuotationResponse quotationResponseFromJson(String str) =>
    QuotationResponse.fromJson(json.decode(str));

class QuotationResponse {
  final bool? success;
  final String? message;
  final String? quotationId;
  final Quotation? quotation;

  QuotationResponse({
    this.success,
    this.message,
    this.quotationId,
    this.quotation,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message'];

    // Handle case where message might be a string (error) or object (success)
    if (msg is String) {
      return QuotationResponse(
        success: false,
        message: msg,
        quotationId: null,
        quotation: null,
      );
    }

    return QuotationResponse(
      success: msg?['success'] ?? false,
      message: msg?['message']?.toString(),
      quotationId: msg?['quotation_id']?.toString(),
      quotation: msg?['quotation'] != null
          ? Quotation.fromJson(msg['quotation'])
          : null,
    );
  }
}

class Quotation {
  final String? id;
  final String? partyName;
  final double? grandTotal;
  final String? currency;
  final String? status;

  Quotation({
    this.id,
    this.partyName,
    this.grandTotal,
    this.currency,
    this.status,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id']?.toString(),
      partyName: json['party_name']?.toString(),
      grandTotal: json['grand_total'] != null
          ? (json['grand_total'] as num).toDouble()
          : null,
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
    );
  }
}
