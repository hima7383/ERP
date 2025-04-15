class PurchaseInvoiceRefund {
  final int purchaseInvoiceRefundId;
  final DateTime invoiceDate;
  final double totalAmount;
  final String? notes;
  final int supplierId;
  final int journalEntryID;
  final String paymentStatus;
  final List<PurchaseInvoiceRefundItem> purchaseReturnItemsDto;
  final List<SupplierPayment> supplierPaymentDtos;

  PurchaseInvoiceRefund({
    required this.purchaseInvoiceRefundId,
    required this.invoiceDate,
    required this.totalAmount,
    this.notes,
    required this.supplierId,
    required this.journalEntryID,
    required this.paymentStatus,
    required this.purchaseReturnItemsDto,
    required this.supplierPaymentDtos,
  });

  factory PurchaseInvoiceRefund.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceRefund(
      purchaseInvoiceRefundId: json['purchaseReturnId'], // Kept as requested
      invoiceDate: DateTime.parse(json['invoiceDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'],
      supplierId: json['supplierId'],
      journalEntryID: json['journalEntryID'],
      paymentStatus: json['paymentStatus'],
      purchaseReturnItemsDto: (json['purchaseReturnItemsDto'] as List?)
              ?.map((item) => PurchaseInvoiceRefundItem.fromJson(item))
              .toList() ??
          [],
      supplierPaymentDtos: (json['supplierPaymentDtos'] as List?)
              ?.map((payment) => SupplierPayment.fromJson(payment))
              .toList() ??
          [],
    );
  }
}

class PurchaseInvoiceRefundItem {
  final int purchaseReturnItemId;
  final int productId;
  final int quantity;
  final double discount;
  final double tax;
  final double unitPrice;
  final double totalPrice;

  PurchaseInvoiceRefundItem({
    required this.purchaseReturnItemId,
    required this.productId,
    required this.quantity,
    required this.discount,
    required this.tax,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PurchaseInvoiceRefundItem.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceRefundItem(
      purchaseReturnItemId: json['purchaseReturnItemId'],
      productId: json['productId'],
      quantity: json['quantity'],
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
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
      amount: (json['amount'] as num).toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
