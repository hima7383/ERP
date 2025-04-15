// customer_entity.dart
class Customer {
  final int customerId;
  final String phoneNumber;
  final String email;
  final String? cachedName; // Will be populated after details fetch

  final dynamic classificationId;
  final int accountId;

  Customer({
    this.cachedName,
    required this.customerId,
    required this.phoneNumber,
    required this.email,
    this.classificationId,
    required this.accountId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      classificationId: json['classificationId'],
      accountId: json['accountId'] ?? 0,
    );
  }
}

class CustomerDetails {
  final String fullName;
  final int customerId;
  final String phoneNumber;
  final String landline;
  final String streetAddress1;
  final String streetAddress2;
  final String city;
  final String zone;
  final String postcode;
  final String country;
  final String currency;
  final double total;
  final double paidToDate;
  final double balanceDue;
  final List<Contact> contacts;
  final List<CustomerInvoice> invoices;
  final List<ClientPayment> payments;
  final List<TransactionDto> transactions;

  CustomerDetails({
    required this.fullName,
    required this.customerId,
    required this.phoneNumber,
    required this.landline,
    required this.streetAddress1,
    required this.streetAddress2,
    required this.city,
    required this.zone,
    required this.postcode,
    required this.country,
    required this.currency,
    required this.total,
    required this.paidToDate,
    required this.balanceDue,
    required this.contacts,
    required this.invoices,
    required this.payments,
    required this.transactions,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      fullName: json['fullName'] ?? '',
      customerId: json['customerId'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      landline: json['landline'] ?? '',
      streetAddress1: json['streetAddress1'] ?? '',
      streetAddress2: json['streetAddress2'] ?? '',
      city: json['city'] ?? '',
      zone: json['zone'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      currency: json['currency'] ?? 'EGP',
      total: (json['total'] as num).toDouble(),
      paidToDate: (json['paidToDate'] as num).toDouble(),
      balanceDue: (json['balanceDue'] as num).toDouble(),
      contacts: (json['contactListDT0s'] as List)
          .map((e) => Contact.fromJson(e))
          .toList(),
      invoices: (json['invoices'] as List)
          .map((e) => CustomerInvoice.fromJson(e))
          .toList(),
      payments: (json['clientPayments'] as List)
          .map((e) => ClientPayment.fromJson(e))
          .toList(),
      transactions: (json['transactionDtos'] as List)
          .map((e) => TransactionDto.fromJson(e))
          .toList(),
    );
  }
}

class Contact {
  final int customerId;
  final int contactListId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String landline;
  final String email;

  Contact({
    required this.customerId,
    required this.contactListId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.landline,
    required this.email,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      customerId: json['customerId'] ?? 0,
      contactListId: json['contactListId'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      landline: json['landline'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class CustomerInvoice {
  final int invoiceID;
  final DateTime invoiceDate;
  final DateTime releaseDate;
  final double total;
  final String paymentStatus;
  final int status;

  CustomerInvoice({
    required this.invoiceID,
    required this.invoiceDate,
    required this.releaseDate,
    required this.total,
    required this.paymentStatus,
    required this.status,
  });

  factory CustomerInvoice.fromJson(Map<String, dynamic> json) {
    return CustomerInvoice(
      invoiceID: json['invoiceID'] ?? 0,
      invoiceDate: DateTime.parse(json['invoiceDate']),
      releaseDate: DateTime.parse(json['releaseDate']),
      total: (json['total'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class ClientPayment {
  final int? invoiceId;
  final dynamic invoice;
  final int customerId;
  final dynamic clientName;
  final dynamic city;
  final dynamic state;
  final dynamic country;
  final dynamic postalCode;
  final dynamic telephone;
  final int id;
  final String paymentMethod;
  final double amount;
  final DateTime createdDate;
  final String addedById;
  final dynamic addedBy;
  final int? treasuryId;
  final dynamic treasury;
  final int? journalEntryID;
  final dynamic journalEntry;
  final String currency;
  final String tenantId;

  ClientPayment({
    this.invoiceId,
    this.invoice,
    required this.customerId,
    this.clientName,
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
    this.treasuryId,
    this.treasury,
    this.journalEntryID,
    this.journalEntry,
    required this.currency,
    required this.tenantId,
  });

  factory ClientPayment.fromJson(Map<String, dynamic> json) {
    return ClientPayment(
      invoiceId: json['invoiceId'],
      invoice: json['invoice'],
      customerId: json['customerId'] ?? 0,
      clientName: json['clientName'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      telephone: json['telephone'],
      id: json['id'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
      addedById: json['addedById'] ?? '',
      addedBy: json['addedBy'],
      treasuryId: json['treasuryId'],
      treasury: json['treasury'],
      journalEntryID: json['journalEntryID'],
      journalEntry: json['journalEntry'],
      currency: json['currency'] ?? '',
      tenantId: json['tenantId'] ?? '',
    );
  }
}

class TransactionDto {
  final int id;
  final String type;
  final DateTime dateTime;
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
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      transaction: json['transaction'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      balanceDue: (json['balanceDue'] as num).toDouble(),
    );
  }
}
