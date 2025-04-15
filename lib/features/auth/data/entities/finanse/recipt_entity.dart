class Receipt {
  final int id;
  final int? journalEntryID;
  final String codeNumber;
  final double amount;
  final String currency;
  final DateTime date;
  final String treasury;
  final String description;
  final List<int> categoriesIds;
  final bool isMultiAccount;
  final bool isFrequent;
  final bool withCostCenter;

  Receipt({
    required this.id,
    this.journalEntryID,
    required this.codeNumber,
    required this.amount,
    required this.currency,
    required this.date,
    required this.treasury,
    required this.description,
    required this.categoriesIds,
    required this.isMultiAccount,
    required this.isFrequent,
    required this.withCostCenter,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] ?? 0,
      journalEntryID: json['journalEntryID'],
      codeNumber: json['codeNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      treasury: json['treasury'] ?? '',
      description: json['description'] ?? '',
      categoriesIds: List<int>.from(json['categoriesIds'] ?? []),
      isMultiAccount: json['isMultiAccount'] ?? false,
      isFrequent: json['isfrequent'] ?? false,
      withCostCenter: json['withCostCenter'] ?? false,
    );
  }
}

class ReceiptDetails {
  final int id;
  final int? journalEntryID;
  final String codeNumber;
  final double amount;
  final String currency;
  final DateTime date;
  final String treasury;
  final String description;
  final List<MultiAccountReceiptItem> multiAccReceiptItems;

  ReceiptDetails({
    required this.id,
    this.journalEntryID,
    required this.codeNumber,
    required this.amount,
    required this.currency,
    required this.date,
    required this.treasury,
    required this.description,
    required this.multiAccReceiptItems,
  });

  factory ReceiptDetails.fromJson(Map<String, dynamic> json) {
    return ReceiptDetails(
      id: json['id'] ?? 0,
      journalEntryID: json['journalEntryID'],
      codeNumber: json['codeNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      treasury: json['treasury'] ?? '',
      description: json['description'] ?? '',
      multiAccReceiptItems: (json['multiAccReceiptItems'] as List?)
              ?.map((e) => MultiAccountReceiptItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MultiAccountReceiptItem {
  final int id;
  final String secondaryAccount;
  final String description;
  final double tax;
  final double amount;
  final double taxAmount;

  MultiAccountReceiptItem({
    required this.id,
    required this.secondaryAccount,
    required this.description,
    required this.tax,
    required this.amount,
    required this.taxAmount,
  });

  factory MultiAccountReceiptItem.fromJson(Map<String, dynamic> json) {
    return MultiAccountReceiptItem(
      id: json['id'] ?? 0,
      secondaryAccount: json['secondaryAccount'] ?? '',
      description: json['description'] ?? '',
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
