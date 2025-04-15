class DebitNote {
  final int debitNoteId;
  final DateTime invoiceDate;
  final double totalAmount;
  final String? notes;
  final int supplierId;
  final int journalEntryID;
  final String? paymentStatus; // Paid, Unpaid, Partially Paid
  final List<DebitNoteItem> debitNoteItemsDto;

  DebitNote({
    required this.debitNoteId,
    required this.invoiceDate,
    required this.totalAmount,
    this.notes,
    required this.supplierId,
    required this.journalEntryID,
    this.paymentStatus,
    required this.debitNoteItemsDto,
  });

  factory DebitNote.fromJson(Map<String, dynamic> json) {
    return DebitNote(
      debitNoteId: json['debitNoteId'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      totalAmount: json['totalAmount'].toDouble(),
      notes: json['notes'],
      supplierId: json['supplierId'],
      journalEntryID: json['journalEntryID'],
      paymentStatus: json['paymentStatus'],
      debitNoteItemsDto: (json['debitNoteItemsDto'] as List)
          .map((item) => DebitNoteItem.fromJson(item))
          .toList(),
    );
  }
}
  class DebitNoteItem {
  final int debitNoteItemId;
  final int productId;
  final int quantity;
  final double discount;
  final double tax;
  final double unitPrice;
  final double totalPrice;

  DebitNoteItem({
    required this.debitNoteItemId,
    required this.productId,
    required this.quantity,
    required this.discount,
    required this.tax,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory DebitNoteItem.fromJson(Map<String, dynamic> json) {
    return DebitNoteItem(
      debitNoteItemId: json['debitNoteItemId'],
      productId: json['productId'],
      quantity: json['quantity'],
      discount: json['discount'].toDouble(),
      tax: json['tax'].toDouble(),
      unitPrice: json['unitPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
    );
  }
}
