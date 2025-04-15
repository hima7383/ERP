class RecurringInvoice {
  final int recurringInvoiceId;
  final String? subscriptionName;
  final int customerId;
  final DateTime startDate;
  final DateTime nextInvoiceDate;
  final int issueEvery;
  final int occurrences;
  final int issueInvoiceBefore;
  final int frequency;
  final bool sendEmail;
  final bool automaticPayment;
  final bool displayRange;
  final bool isActive;
  final double discount;
  final double total;
  final List<RecurringInvoiceItem>? items;

  RecurringInvoice({
    required this.recurringInvoiceId,
    this.subscriptionName,
    required this.customerId,
    required this.startDate,
    required this.nextInvoiceDate,
    required this.issueEvery,
    required this.occurrences,
    required this.issueInvoiceBefore,
    required this.frequency,
    required this.sendEmail,
    required this.automaticPayment,
    required this.displayRange,
    required this.isActive,
    required this.discount,
    required this.total,
    this.items,
  });

  factory RecurringInvoice.fromJson(Map<String, dynamic> json) {
    return RecurringInvoice(
      recurringInvoiceId: json['recurringInvoiceId'] ?? 0,
      subscriptionName: json['subscriptionName'],
      customerId: json['customerId'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      nextInvoiceDate: DateTime.parse(json['nextInvoiceDate']),
      issueEvery: json['issueEvery'] ?? 0,
      occurrences: json['occurrences'] ?? 0,
      issueInvoiceBefore: json['issueInvoiceBefore'] ?? 0,
      frequency: json['frequency'] ?? 0,
      sendEmail: json['sendEmail'] ?? false,
      automaticPayment: json['automaticPayment'] ?? false,
      displayRange: json['displayRange'] ?? false,
      isActive: json['isActive'] ?? false,
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      items: json['recurringInvoiceItemsDto'] != null
          ? (json['recurringInvoiceItemsDto'] as List)
              .map((e) => RecurringInvoiceItem.fromJson(e))
              .toList()
          : null,
    );
  }
}

class RecurringInvoiceItem {
  final int recurringInvoiceId;
  final int productId;
  final int quantity;
  final String description;
  final double unitPrice;
  final double discount;
  final double totalPrice;

  RecurringInvoiceItem({
    required this.recurringInvoiceId,
    required this.productId,
    required this.quantity,
    required this.description,
    required this.unitPrice,
    required this.discount,
    required this.totalPrice,
  });

  factory RecurringInvoiceItem.fromJson(Map<String, dynamic> json) {
    return RecurringInvoiceItem(
      recurringInvoiceId: json['recurringInvoiceId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}