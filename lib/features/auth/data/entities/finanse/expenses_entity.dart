class Expense {
  final int id;
  final int? journalEntryID;
  final String codeNumber;
  final double amount;
  final String currency;
  final DateTime date;
  final String treasury;
  final String description;
  final List<int> categoriesIds;
  final int? supplierId;
  final bool isMultiAccount;
  final bool isFrequent;
  final bool withCostCenter;

  Expense({
    required this.id,
    this.journalEntryID,
    required this.codeNumber,
    required this.amount,
    required this.currency,
    required this.date,
    required this.treasury,
    required this.description,
    required this.categoriesIds,
    this.supplierId,
    required this.isMultiAccount,
    required this.isFrequent,
    required this.withCostCenter,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      journalEntryID: json['journalEntryID'],
      codeNumber: json['codeNumber'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? '',
      date: DateTime.parse(json['date']),
      treasury: json['treasury'] ?? '',
      description: json['description'] ?? '',
      categoriesIds: List<int>.from(json['categoriesIds'] ?? []),
      supplierId: json['supplierId'],
      isMultiAccount: json['isMultiAccount'] ?? false,
      isFrequent: json['isfrequent'] ?? false,
      withCostCenter: json['withCostCenter'] ?? false,
    );
  }
}

class ExpenseDetails {
  final int id;
  final int? journalEntryID;
  final String codeNumber;
  final double amount;
  final String currency;
  final DateTime date;
  final String treasury;
  final String description;
  final List<MultiAccountExpenseItem> multiAccExpenseItems;

  ExpenseDetails({
    required this.id,
    this.journalEntryID,
    required this.codeNumber,
    required this.amount,
    required this.currency,
    required this.date,
    required this.treasury,
    required this.description,
    required this.multiAccExpenseItems,
  });

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) {
    return ExpenseDetails(
      id: json['id'] ?? 0,
      journalEntryID: json['journalEntryID'],
      codeNumber: json['codeNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Handle null
      currency: json['currency'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ??
          DateTime.now(), // Handle null
      treasury: json['treasury'] ?? '',
      description: json['description'] ?? '',
      multiAccExpenseItems: (json['multiAccExpenseItems'] as List?)
              ?.map((e) => MultiAccountExpenseItem.fromJson(e))
              .toList() ??
          [], // Handle null
    );
  }
}

class MultiAccountExpenseItem {
  final int id;
  final String secondaryAccount;
  final String description;
  final double tax;
  final double amount;
  final double taxAmount;

  MultiAccountExpenseItem({
    required this.id,
    required this.secondaryAccount,
    required this.description,
    required this.tax,
    required this.amount,
    required this.taxAmount,
  });

  factory MultiAccountExpenseItem.fromJson(Map<String, dynamic> json) {
    return MultiAccountExpenseItem(
      id: json['id'] ?? 0,
      secondaryAccount: json['secondaryAccount'] ?? '',
      description: json['description'] ?? '',
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0, // Handle null
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Handle null
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0, // Handle null
    );
  }
}
