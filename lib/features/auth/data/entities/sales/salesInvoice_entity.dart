class SalesInvoice {
  final int invoiceId;
  final int customerID;
  final DateTime invoiceDate;
  final DateTime releaseDate;
  final int paymentTerms;
  final double tax;
  final double discount;
  final double total;
  final int status;
  final int? journalEntryID;
  final int? salesCostEntryID;
  final String paymentStatus;
  final List<InvoiceItem>? invoiceItems;
  final List<ClientPaymentDto>? clientPayments;

  SalesInvoice({
    required this.invoiceId,
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

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      invoiceId: json['invoiceId'] ?? 0,
      customerID: json['customerID'] ?? 0,
      invoiceDate: DateTime.parse(json['invoiceDate']),
      releaseDate: DateTime.parse(json['releaseDate']),
      paymentTerms: json['paymentTerms'] ?? 0,
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
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
  final int invoiceId;
  final int invoiceItemId;
  final int productId;
  final int quantity;
  final String description;
  final double discount;
  final double tax;
  final double unitPrice;
  final double totalPrice;

  InvoiceItem({
    required this.invoiceId,
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
      invoiceId: json['invoiceId'] ?? 0,
      invoiceItemId: json['invoiceItemId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
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
      amount: (json['amount'] as num).toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}