import 'dart:convert';

QuotationResponse quotationResponseFromJson(String str) =>
    QuotationResponse.fromJson(json.decode(str));

class QuotationResponse {
  final bool success;
  final String message;
  final String quotationId;
  final Quotation quotation;

  QuotationResponse({
    required this.success,
    required this.message,
    required this.quotationId,
    required this.quotation,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message'];
    return QuotationResponse(
      success: msg['success'],
      message: msg['message'],
      quotationId: msg['quotation_id'],
      quotation: Quotation.fromJson(msg['quotation']),
    );
  }
}

class Quotation {
  final String id;
  final String partyName;
  final double grandTotal;
  final String currency;
  final String status;

  Quotation({
    required this.id,
    required this.partyName,
    required this.grandTotal,
    required this.currency,
    required this.status,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'],
      partyName: json['party_name'],
      grandTotal: (json['grand_total'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
    );
  }
}
