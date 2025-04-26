import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp/features/auth/data/entities/accounts/daily.dart';
import 'package:erp/features/auth/data/entities/accounts/dailyitem.dart';
import 'package:erp/features/auth/logic/accounts/daily.dart';

class JournalEntryScreen extends StatelessWidget {
  const JournalEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Journal Entries',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            // Modern search bar
            _buildSearchBar(context),
            const SizedBox(height: 16),
            // Journal entries list with improved spacing
            Expanded(
              child: BlocBuilder<JournalEntryCubit, JournalEntryState>(
                builder: (context, state) {
                  if (state is JournalEntryLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.8),
                        strokeWidth: 2.5,
                      ),
                    );
                  } else if (state is JournalEntryError) {
                    return  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No internet connection",
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your connection",
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                            ),
                            ),
                            onPressed: () => context.read<JournalEntryCubit>().fetchJournalEntries(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
                  } else if (state is JournalEntryLoaded) {
                    if (state.entries.isEmpty) {
                      return Center(
                        child: Text(
                          "No journal entries found",
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      );
                    }
                    return _buildEntriesList(context, state.entries);
                  }
                  return Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search by description or ID...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon:
            Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[400]!, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
      onChanged: (query) =>
          context.read<JournalEntryCubit>().searchJournalEntries(query),
    );
  }

  Widget _buildEntriesList(BuildContext context, List<JournalEntry> entries) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<JournalEntryCubit>().fetchJournalEntries();
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4),
        physics: const BouncingScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _buildEntryTile(context, entries[index]),
      ),
    );
  }

  Widget _buildEntryTile(BuildContext context, JournalEntry entry) {
    final totalAmount =
        entry.items.fold(0.0, (sum, item) => sum + (item.debit - item.credit));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showEntryDetails(context, entry),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "JE-${entry.journalEntryID}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: totalAmount == 0
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${totalAmount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: totalAmount == 0
                            ? Colors.greenAccent[400]
                            : Colors.redAccent[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.description,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    entry.entryDate.toIso8601String(),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${entry.items.length} ${entry.items.length == 1 ? 'item' : 'items'}",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'JE-${entry.journalEntryID}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Date', entry.entryDate.toIso8601String()),
                        const SizedBox(height: 12),
                        _buildDetailRow('Description', entry.description),
                        const SizedBox(height: 16),
                        const Text(
                          'Line Items',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...entry.items
                            .map((item) => _buildItemCard(item))
                            .toList(),
                      ],
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                          ),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(JournalEntryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.accountName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child:
                    _buildAmountPill('Debit', item.debit, Colors.greenAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child:
                    _buildAmountPill('Credit', item.credit, Colors.redAccent),
              ),
            ],
          ),
          if (item.costCenterName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Cost Center: ${item.costCenterName}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountPill(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
            ),
          ),
          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
