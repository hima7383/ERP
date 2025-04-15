class PurchaseInvoice {
  final int purchaseInvoiceId;
  final DateTime invoiceDate;
  final double totalAmount;
  final String notes;
  final int supplierId;
  final int journalEntryID;
  final String paymentStatus; // Paid, Unpaid, Partially Paid
  final List<PurchaseInvoiceItem> items;
  final List<SupplierPayment> supplierPayments;

  PurchaseInvoice({
    required this.purchaseInvoiceId,
    required this.invoiceDate,
    required this.totalAmount,
    required this.notes,
    required this.supplierId,
    required this.journalEntryID,
    required this.paymentStatus,
    required this.items,
    required this.supplierPayments,
  });

  factory PurchaseInvoice.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoice(
      purchaseInvoiceId: json['purchaseInvoiceId'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      totalAmount: json['totalAmount'].toDouble(),
      notes: json['notes'],
      supplierId: json['supplierId'],
      journalEntryID: json['journalEntryID'],
      paymentStatus: json['paymentStatus'],
      items: (json['purchaseInvoiceItemsDto'] as List)
          .map((item) => PurchaseInvoiceItem.fromJson(item))
          .toList(),
      supplierPayments: (json['supplierPaymentDtos'] as List)
          .map((payment) => SupplierPayment.fromJson(payment))
          .toList(),
    );
  }
}

class PurchaseInvoiceItem {
  final int purchaseInvoiceItemId;
  final int productId;
  final int quantity;
  final double discount;
  final double tax;
  final double unitPrice;
  final double totalPrice;

  PurchaseInvoiceItem({
    required this.purchaseInvoiceItemId,
    required this.productId,
    required this.quantity,
    required this.discount,
    required this.tax,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PurchaseInvoiceItem.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceItem(
      purchaseInvoiceItemId: json['purchaseInvoiceItemId'],
      productId: json['productId'],
      quantity: json['quantity'],
      discount: json['discount'].toDouble(),
      tax: json['tax'].toDouble(),
      unitPrice: json['unitPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
    );
  }
}

class SupplierPayment {
  final int id;
  final String supplierName;
  final String paymentMethod;
  final double amount;
  final DateTime createdDate;

  SupplierPayment({
    required this.id,
    required this.supplierName,
    required this.paymentMethod,
    required this.amount,
    required this.createdDate,
  });

  factory SupplierPayment.fromJson(Map<String, dynamic> json) {
    return SupplierPayment(
      id: json['id'],
      supplierName: json['supplierName'],
      paymentMethod: json['paymentMethod'],
      amount: json['amount'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
