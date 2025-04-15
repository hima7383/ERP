class Account {
  final int accountID;
  final String accountName;
  final int type; // 0 for primary, 1 for secondary
  final int? parentAccountID; // Null for primary accounts
  final bool isActive;
  final String createdDate;
  final List<Account> childAccounts; // Nested child accounts
  final double balance;

  Account({
    required this.balance,
    required this.accountID,
    required this.accountName,
    required this.type,
    this.parentAccountID,
    required this.isActive,
    required this.createdDate,
    required this.childAccounts,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountID: json['accountID'],
      accountName: json['accountName'],
      type: json['type'],
      parentAccountID: json['parentAccountID'],
      isActive: json['isActive'],
      balance: json['balance'].toDouble(),
      createdDate: json['createdDate'],
      childAccounts: (json['childAccounts'] as List<dynamic>?)
              ?.map((child) => Account.fromJson(child))
              .toList() ??
          [], // Handle null childAccounts
    );
  }
}
class Assets {
  final int accountID;
  final String accountName;
  final int type;
  final int parentAccountID;
  final bool isActive;
  final DateTime accCreatedDate; // Parsed into DateTime
  final double balance;
  final List<dynamic> journalEntrys; // Type of items unknown, using List<dynamic>

  Assets({
    required this.accountID,
    required this.accountName,
    required this.type,
    required this.parentAccountID,
    required this.isActive,
    required this.accCreatedDate,
    required this.balance,
    required this.journalEntrys,
  });

  factory Assets.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      // Handle potential parsing errors or default date '0001-01-01...'
      parsedDate = DateTime.parse(json['accCreatedDate'] as String);
    } catch (e) {
      // Handle error: Use a default date, or rethrow, or make nullable
      print("Error parsing date: ${json['accCreatedDate']}. Error: $e");
      parsedDate = DateTime(1, 1, 1); // Default fallback
      // Or consider making accCreatedDate nullable: DateTime?
    }

    return Assets(
      accountID: json['accountID'] as int,
      accountName: json['accountName'] as String? ?? '', // Handle potential null/missing names
      type: json['type'] as int,
      parentAccountID: json['parentAccountID'] as int,
      isActive: json['isActive'] as bool,
      accCreatedDate: parsedDate,
      // Ensure balance is treated as double, handle int if necessary
      balance: (json['balance'] as num).toDouble(),
      // Assume journalEntrys is always a list, even if empty
      journalEntrys: json['journalEntrys'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountID': accountID,
      'accountName': accountName,
      'type': type,
      'parentAccountID': parentAccountID,
      'isActive': isActive,
      // Format DateTime back to ISO 8601 string
      'accCreatedDate': accCreatedDate.toIso8601String(),
      'balance': balance,
      'journalEntrys': journalEntrys, // Assuming items in list are directly serializable
    };
  }
}
class SequenceData {
  final List<int> sequence;

  SequenceData({
    required this.sequence,
  });

  factory SequenceData.fromJson(Map<String, dynamic> json) {
    // Manually handle the key name 'squence'
    var list = json['squence'] as List<dynamic>? ?? []; // Handle null or missing key
    // Convert dynamic list items to int, handle potential type errors
    List<int> intList = list.map((item) => item as int).toList();

    return SequenceData(
      sequence: intList,
    );
  }

  Map<String, dynamic> toJson() {
    // Manually use the key name 'squence' during serialization
    return {
      'squence': sequence,
    };
  }
}

