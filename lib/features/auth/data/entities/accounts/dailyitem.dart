class JournalEntryItem {
  final int journalEntryDetailID;
  final int journalEntryID;
  final String description;
  final String accountName;
  final int accountID;
  final double debit;
  final double credit;
  final String? costCenterName;
  final int? costCenterId;

  JournalEntryItem({
    required this.journalEntryDetailID,
    required this.journalEntryID,
    required this.description,
    required this.accountName,
    required this.accountID,
    required this.debit,
    required this.credit,
    this.costCenterName,
    this.costCenterId,
  });

  factory JournalEntryItem.fromJson(Map<String, dynamic> json) {
    return JournalEntryItem(
      journalEntryDetailID: json['journalEntryDetailID'],
      journalEntryID: json['journalEntryID'],
      description: json['description'],
      accountName: json['accountName'],
      accountID: json['accountID'],
      debit: json['debit'].toDouble(),
      credit: json['credit'].toDouble(),
      costCenterName: json['costCenterName'],
      costCenterId: json['costCenterId'],
    );
  }
}