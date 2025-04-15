import 'package:erp/features/auth/data/entities/accounts/dailyitem.dart';

class JournalEntry {
  final int journalEntryID;
  final DateTime entryDate;
  final String description;
  final List<JournalEntryItem> items;

  JournalEntry({
    required this.journalEntryID,
    required this.entryDate,
    required this.description,
    required this.items,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      journalEntryID: json['journalEntryID'],
      entryDate: DateTime.parse(json['entryDate']),
      description: json['description'],
      items: (json['journalEntryItemsDto'] as List)
          .map((item) => JournalEntryItem.fromJson(item))
          .toList(),
    );
  }
}