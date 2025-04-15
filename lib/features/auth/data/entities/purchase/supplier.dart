class Supplier {
  final int supplierId;
  final String supplierName;
  final int accountId;

  Supplier({
    required this.supplierId,
    required this.supplierName,
    required this.accountId,
  });

  // Convert JSON to Supplier object
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: json['supplierId'] as int,
      supplierName: json['supplierName'] as String,
      accountId: json['accountId'] as int,
    );
  }
}

class SupplierData {
  final int supplierId;
  final String supplierName;
  final String? contactInfo; // Made nullable
  final String? address; // Made nullable
  final int accountId;
  final double total;
  final double paidToDate;
  final double balanceDue;
  final List<PurchaseInvoice> purchaseInvoices;
  final List<SupplierPayment> supplierPayments;
  final List<TransactionDto> transactionDtos;

  SupplierData({
    required this.supplierId,
    required this.supplierName,
    this.contactInfo,
    this.address,
    required this.accountId,
    required this.total,
    required this.paidToDate,
    required this.balanceDue,
    required this.purchaseInvoices,
    required this.supplierPayments,
    required this.transactionDtos,
  });

  factory SupplierData.fromJson(Map<String, dynamic> json) {
    return SupplierData(
      supplierId: json['supplierId'] as int,
      supplierName: json['supplierName'] as String,
      contactInfo: json['contactInfo'] as String?,
      address: json['address'] as String?,
      accountId: json['accountId'] as int,
      total: (json['total'] as num).toDouble(),
      paidToDate: (json['paidToDate'] as num).toDouble(),
      balanceDue: (json['balanceDue'] as num).toDouble(),
      purchaseInvoices: (json['purchaseInvoices'] as List)
          .map((x) => PurchaseInvoice.fromJson(x as Map<String, dynamic>))
          .toList(),
      supplierPayments: (json['supplierPayments'] as List)
          .map((x) => SupplierPayment.fromJson(x as Map<String, dynamic>))
          .toList(),
      transactionDtos: (json['transactionDtos'] as List)
          .map((x) => TransactionDto.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PurchaseInvoice {
  final int purchaseInvoiceId;
  final String invoiceDate;
  final double totalAmount;
  final String? notes; // Made nullable
  final bool isPaid;
  final int numberOfDaysToPay;
  final int supplierId;
  final int journalEntryID;
  final dynamic journalEntry;
  final int paymentStatusId;
  final PaymentStatus paymentStatus;
  final List<dynamic> items;
  final String tenantId;

  PurchaseInvoice({
    required this.purchaseInvoiceId,
    required this.invoiceDate,
    required this.totalAmount,
    this.notes,
    required this.isPaid,
    required this.numberOfDaysToPay,
    required this.supplierId,
    required this.journalEntryID,
    this.journalEntry,
    required this.paymentStatusId,
    required this.paymentStatus,
    required this.items,
    required this.tenantId,
  });

  factory PurchaseInvoice.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoice(
      purchaseInvoiceId: json['purchaseInvoiceId'] as int,
      invoiceDate: json['invoiceDate'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      isPaid: json['isPaid'] as bool,
      numberOfDaysToPay: json['numberOfDaysToPay'] as int,
      supplierId: json['supplierId'] as int,
      journalEntryID: json['journalEntryID'] as int,
      journalEntry: json['journalEntry'],
      paymentStatusId: json['paymentStatusId'] as int,
      paymentStatus:
          PaymentStatus.fromJson(json['paymentStatus'] as Map<String, dynamic>),
      items: json['items'] as List<dynamic>,
      tenantId: json['tenantId'] as String,
    );
  }
}

class PaymentStatus {
  final int id;
  final String name;
  final String description;

  PaymentStatus({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}

class SupplierPayment {
  final int supplierId;
  final int? purchaseInvoiceId;
  final dynamic purchaseInvoice;
  final int? purchaseReturnId;
  final dynamic purchaseReturn;
  final String supplierName;
  final String? city; // Made nullable
  final String? state; // Made nullable
  final String? country; // Made nullable
  final String? postalCode; // Made nullable
  final String? telephone; // Made nullable
  final int id;
  final String paymentMethod;
  final double amount;
  final String createdDate;
  final String addedById;
  final dynamic addedBy;
  final int treasuryId;
  final dynamic treasury;
  final int journalEntryID;
  final dynamic journalEntry;
  final String currency;
  final String tenantId;

  SupplierPayment({
    required this.supplierId,
    this.purchaseInvoiceId,
    this.purchaseInvoice,
    this.purchaseReturnId,
    this.purchaseReturn,
    required this.supplierName,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.telephone,
    required this.id,
    required this.paymentMethod,
    required this.amount,
    required this.createdDate,
    required this.addedById,
    this.addedBy,
    required this.treasuryId,
    this.treasury,
    required this.journalEntryID,
    this.journalEntry,
    required this.currency,
    required this.tenantId,
  });

  factory SupplierPayment.fromJson(Map<String, dynamic> json) {
    return SupplierPayment(
      supplierId: json['supplierId'] as int,
      purchaseInvoiceId: json['purchaseInvoiceId'] as int?,
      purchaseInvoice: json['purchaseInvoice'],
      purchaseReturnId: json['purchaseReturnId'] as int?,
      purchaseReturn: json['purchaseReturn'],
      supplierName: json['supplierName'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      telephone: json['telephone'] as String?,
      id: json['id'] as int,
      paymentMethod: json['paymentMethod'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdDate: json['createdDate'] as String,
      addedById: json['addedById'] as String,
      addedBy: json['addedBy'],
      treasuryId: json['treasuryId'] as int,
      treasury: json['treasury'],
      journalEntryID: json['journalEntryID'] as int,
      journalEntry: json['journalEntry'],
      currency: json['currency'] as String,
      tenantId: json['tenantId'] as String,
    );
  }
}

class TransactionDto {
  final int id;
  final String type;
  final String dateTime;
  final String transaction;
  final double amount;
  final double balanceDue;

  TransactionDto({
    required this.id,
    required this.type,
    required this.dateTime,
    required this.transaction,
    required this.amount,
    required this.balanceDue,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as int,
      type: json['type'] as String,
      dateTime: json['dateTime'] as String,
      transaction: json['transaction'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceDue: (json['balanceDue'] as num).toDouble(),
    );
  }
}
