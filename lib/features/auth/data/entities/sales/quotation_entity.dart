
import 'package:flutter/material.dart';

class Quotation {
  final int quotationId;
  final int customerId;
  final int? invoiceId;
  final DateTime quoteDate;
  final DateTime expiryDate;
  final double discount;
  final double grandTotal;
  final int status;
  final List<QuotationItem>? items;

  Quotation({
    required this.quotationId,
    required this.customerId,
    this.invoiceId,
    required this.quoteDate,
    required this.expiryDate,
    required this.discount,
    required this.grandTotal,
    required this.status,
    this.items,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      quotationId: json['quotationId'] ?? 0,
      customerId: json['customerID'] ?? 0,
      invoiceId: json['invoiceId'],
      quoteDate: DateTime.parse(json['quoteDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      discount: (json['discount'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      status: json['status'] ?? 0,
      items: json['quotationItemsDto'] != null
          ? (json['quotationItemsDto'] as List)
              .map((e) => QuotationItem.fromJson(e))
              .toList()
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 0: return 'Draft';
      case 1: return 'Sent';
      case 2: return 'Accepted';
      case 3: return 'Rejected';
      case 4: return 'Expired';
      default: return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0: return Colors.grey;
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.orange;
      default: return Colors.grey;
    }
  }
}

class QuotationItem {
  final int quotationId;
  final int productId;
  final int quantity;
  final String description;
  final double unitPrice;
  final double discount;
  final double totalPrice;

  QuotationItem({
    required this.quotationId,
    required this.productId,
    required this.quantity,
    required this.description,
    required this.unitPrice,
    required this.discount,
    required this.totalPrice,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      quotationId: json['quotationId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}