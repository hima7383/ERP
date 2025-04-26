class SalesInvoiceRefund {
  final int refundInvoiceId;
  final int customerID;
  final DateTime invoiceDate;
  final DateTime releaseDate;
  final int paymentTerms;
  final double tax;
  final double discount;
  final double total;
  final int status;
  final String? notes;
  final int? journalEntryID;
  final int? salesCostEntryID;
  final String paymentStatus;
  final List<InvoiceItem>? invoiceItems;
  final List<ClientPaymentDto>? clientPayments;

  SalesInvoiceRefund({
    this.notes,
    required this.refundInvoiceId,
    required this.customerID,
    required this.invoiceDate,
    required this.releaseDate,
    required this.paymentTerms,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    this.journalEntryID,
    this.salesCostEntryID,
    required this.paymentStatus,
    this.invoiceItems,
    this.clientPayments,
  });

  factory SalesInvoiceRefund.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceRefund(
      notes: json['notes'],
      refundInvoiceId: json['refundInvoiceId'] ?? 0,
      customerID: json['customerID'] ?? 0,
      invoiceDate:
          DateTime.parse(json['invoiceDate'] ?? DateTime.now().toString()),
      releaseDate:
          DateTime.parse(json['releaseDate'] ?? DateTime.now().toString()),
      paymentTerms: json['paymentTerms'] ?? 0,
      tax: (json['tax'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      journalEntryID: json['journalEntryID'],
      salesCostEntryID: json['salesCostEntryID'],
      paymentStatus: json['paymentStatus'] ?? '',
      invoiceItems: json['invoiceItemsDto'] != null
          ? (json['invoiceItemsDto'] as List)
              .map((e) => InvoiceItem.fromJson(e))
              .toList()
          : null,
      clientPayments: json['clientPaymentDtos'] != null
          ? (json['clientPaymentDtos'] as List)
              .map((e) => ClientPaymentDto.fromJson(e))
              .toList()
          : null,
    );
  }
}

class InvoiceItem {
  final String? notes;
  final int refundInvoiceId;
  final int invoiceItemId;
  final int productId;
  final int quantity;
  final String description;
  final double discount;
  final double tax;
  final double unitPrice;
  final double totalPrice;

  InvoiceItem({
    this.notes,
    required this.refundInvoiceId,
    required this.invoiceItemId,
    required this.productId,
    required this.quantity,
    required this.description,
    required this.discount,
    required this.tax,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      notes: json['notes'],
      refundInvoiceId: json['refundInvoiceId'] ?? 0,
      invoiceItemId: json['invoiceItemId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}

class ClientPaymentDto {
  final int id;
  final String? clientName;
  final String paymentMethod;
  final double amount;
  final DateTime createdDate;

  ClientPaymentDto({
    required this.id,
    this.clientName,
    required this.paymentMethod,
    required this.amount,
    required this.createdDate,
  });

  factory ClientPaymentDto.fromJson(Map<String, dynamic> json) {
    return ClientPaymentDto(
      id: json['id'] ?? 0,
      clientName: json['clientName'],
      paymentMethod: json['paymentMethod'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdDate:
          DateTime.parse(json['createdDate'] ?? DateTime.now().toString()),
    );
  }
}
