import 'package:flutter/foundation.dart'; // For debugPrint

// Basic Placeholder - Define fields based on actual API response if available
class StockTransaction {
  final int transactionId;
  final DateTime transactionDate;
  final String type; // e.g., 'IN', 'OUT', 'ADJUST'
  // Add other relevant fields: productId, quantity, etc.

  StockTransaction({
    required this.transactionId,
    required this.transactionDate,
    required this.type,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    // Implement parsing based on actual API structure
    return StockTransaction(
      transactionId: json['transactionId'] ?? 0,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : DateTime.now(), // Provide a default or handle null properly
      type: json['type'] ?? 'UNKNOWN',
    );
  }
}

// Basic Placeholder - Define fields based on actual API response if available
class DeliveryVoucher {
  final int deliveryVoucherId;
  final DateTime deliveryDate;
  // Add other relevant fields: customerId, status, items, etc.

  DeliveryVoucher({
    required this.deliveryVoucherId,
    required this.deliveryDate,
  });

  factory DeliveryVoucher.fromJson(Map<String, dynamic> json) {
    // Implement parsing based on actual API structure
    return DeliveryVoucher(
      deliveryVoucherId: json['deliveryVoucherId'] ?? 0,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : DateTime.now(), // Provide a default or handle null properly
    );
  }
}

class ReceivingVoucher {
  final int receivingVoucherId;
  final DateTime receivingDate;
  final String? notes;
  final int warehouseId;
  // Note: Included nested Warehouse summary for context if needed, but might cause issues if API cycles.
  // Consider removing if not strictly necessary for display within the voucher context.
  final WarehouseSummary? warehouseSummary; // Use a summary to avoid deep nesting cycles
  final int accountId;
  final int voucherStatusId;
  final int supplierId;
  final int journalEntryID;
  final int? purchaseInvoiceId; // Made nullable based on API possibility
  final List<dynamic> receivingVoucherItems; // Replace 'dynamic' with a proper Item class if structure is known
  final String tenantId;

  ReceivingVoucher({
    required this.receivingVoucherId,
    required this.receivingDate,
    this.notes,
    required this.warehouseId,
    this.warehouseSummary,
    required this.accountId,
    required this.voucherStatusId,
    required this.supplierId,
    required this.journalEntryID,
    this.purchaseInvoiceId,
    required this.receivingVoucherItems,
    required this.tenantId,
  });

  factory ReceivingVoucher.fromJson(Map<String, dynamic> json) {
    return ReceivingVoucher(
      receivingVoucherId: json['receivingVoucherId'] ?? 0,
      receivingDate: DateTime.parse(json['receivingDate']),
      notes: json['notes'],
      warehouseId: json['warehouseId'] ?? 0,
      // Parse nested summary carefully, avoid infinite loops if API allows deep nesting
      warehouseSummary: json['warehouse'] != null
          ? WarehouseSummary.fromJson(json['warehouse'])
          : null,
      accountId: json['accountId'] ?? 0,
      voucherStatusId: json['voucherStatusId'] ?? 0,
      supplierId: json['supplierId'] ?? 0,
      journalEntryID: json['journalEntryID'] ?? 0,
      purchaseInvoiceId: json['purchaseInvoiceId'], // Can be null
      // TODO: Replace 'dynamic' with mapping to a specific Item class if structure is known
      receivingVoucherItems: json['receivingVoucherItems'] as List? ?? [],
      tenantId: json['tenantId'] ?? '',
    );
  }
}

// Represents the full Warehouse details, potentially including populated lists
class Warehouse {
  final int warehouseId;
  final String warehouseName;
  final String? address;
  final List<StockTransaction> stockTransactions;
  final List<ReceivingVoucher> receivingVouchers;
  final List<DeliveryVoucher> deliveryVouchers;

  Warehouse({
    required this.warehouseId,
    required this.warehouseName,
    this.address,
    required this.stockTransactions,
    required this.receivingVouchers,
    required this.deliveryVouchers,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    try {
      return Warehouse(
        warehouseId: json['warehouseId'] ?? 0,
        warehouseName: json['warehouseName'] ?? 'Unknown Warehouse',
        address: json['address'], // Address can be null
        stockTransactions: (json['stockTransactions'] as List?)
                ?.map((e) => StockTransaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        receivingVouchers: (json['receivingVouchers'] as List?)
                ?.map((e) => ReceivingVoucher.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        deliveryVouchers: (json['deliveryVouchers'] as List?)
                ?.map((e) => DeliveryVoucher.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint("Error parsing Warehouse JSON: $e \nJSON: $json");
      // Return a default or throw a custom exception
       return Warehouse(
         warehouseId: json['warehouseId'] ?? 0,
         warehouseName: 'Error Parsing Warehouse',
         address: null,
         stockTransactions: [],
         receivingVouchers: [],
         deliveryVouchers: [],
       );
    }
  }
}

// A lightweight summary used for nested representation to avoid cycles.
// Ensure the fields match what's actually nested in ReceivingVoucher's 'warehouse' field.
class WarehouseSummary {
   final int warehouseId;
   final String warehouseName;
   final String? address;
   // Add other fields ONLY if they are present in the nested 'warehouse' object within ReceivingVoucher

   WarehouseSummary({
    required this.warehouseId,
    required this.warehouseName,
    this.address,
   });

    factory WarehouseSummary.fromJson(Map<String, dynamic> json) {
     return WarehouseSummary(
        warehouseId: json['warehouseId'] ?? 0,
        warehouseName: json['warehouseName'] ?? 'Unknown',
        address: json['address'],
     );
   }
}