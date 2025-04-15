// --- invoice_item_dto.dart ---

class InvoiceItemDTO {
  final int productId;
  final int quantity;
  final String description;
  final double discount; // Assuming percentage (e.g., 10 for 10%) or amount? API needs clarification. Let's assume amount for now.
  final double tax;      // Assuming percentage (e.g., 20 for 20%) or amount? API needs clarification. Let's assume amount for now.
  final double unitPrice;
  final double totalPrice; // Calculated: quantity * unitPrice - discount + tax (Adjust formula based on actual logic)

  const InvoiceItemDTO({
    required this.productId,
    required this.quantity,
    required this.description,
    required this.discount,
    required this.tax,
    required this.unitPrice,
    required this.totalPrice,
  });

  // If you need to update items after creation (e.g., in the list)
  InvoiceItemDTO copyWith({
    int? productId,
    int? quantity,
    String? description,
    double? discount,
    double? tax,
    double? unitPrice,
    double? totalPrice,
  }) {
    return InvoiceItemDTO(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'description': description,
      'discount': discount,
      'tax': tax,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  // Add fromJson if needed for other features
}

// --- invoice_create_dto.dart ---


class InvoiceCreateDTO {
  final int customerID;
  final DateTime invoiceDate;
  final DateTime releaseDate;
  final int paymentTerms; // Assuming this is an ID or enum value based on your API
  final double tax;       // Overall tax amount for the invoice
  final double discount;  // Overall discount amount for the invoice
  final double total;     // Overall final total for the invoice
  final bool alreadyPaid;
  final double amountPaid;
  final List<InvoiceItemDTO> invoiceItemDT0s; // Corrected typo from API spec (DT0s -> DTOs)

  const InvoiceCreateDTO({
    required this.customerID,
    required this.invoiceDate,
    required this.releaseDate,
    required this.paymentTerms,
    required this.tax,
    required this.discount,
    required this.total,
    required this.alreadyPaid,
    required this.amountPaid,
    required this.invoiceItemDT0s,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerID': customerID,
      // Format dates to ISO 8601 string format expected by the API
      'invoiceDate': invoiceDate.toIso8601String(),
      'releaseDate': releaseDate.toIso8601String(),
      'paymentTerms': paymentTerms,
      'tax': tax,
      'discount': discount,
      'total': total,
      'alreadyPaid': alreadyPaid,
      'amountPaid': amountPaid,
      // Ensure items are converted to JSON maps
      'invoiceItemDT0s': invoiceItemDT0s.map((item) => item.toJson()).toList(),
    };
  }

   // Add fromJson if needed
}