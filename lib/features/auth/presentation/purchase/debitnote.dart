import 'package:erp/features/auth/data/entities/purchase/debit_note.dart';
import 'package:erp/features/auth/logic/purchase/debitnote_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart'; // Import Gap

// Renamed class to follow Dart conventions (UpperCamelCase)
// Converted to StatefulWidget for initState data fetching
class DebitNoteScreen extends StatefulWidget {
  const DebitNoteScreen({super.key});

  @override
  State<DebitNoteScreen> createState() => _DebitNoteScreenState();
}

class _DebitNoteScreenState extends State<DebitNoteScreen> {
  @override
  void initState() {
    // Fetch data when the screen loads
    // Assuming the cubit method is fetchDebitNotes or similar
    context.read<DebitnoteCubit>().fetchDebitnoteCubits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        title: const Text( // Modern AppBar title style
          'Debit Notes', // Updated title slightly for clarity
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false, // Left-align title
        iconTheme: const IconThemeData(color: Colors.white), // White icons
      ),
      body: BlocListener<DebitnoteCubit, DebitnoteCubitState>(
        listener: (context, state) {
          // Listen for the state that contains the selected DebitNote for the popup
          if (state is DebitnoteCubitLoaded && state.selectedInvoice != null) {
            _showDebitNoteDetailsPopup(context, state.selectedInvoice!,
                state.productNames, state.supplierNames);
          }
          // Optional: Handle a state specifically for loading single details if needed
          // else if (state is DebitNoteDetailsLoaded) {
          //   _showDebitNoteDetailsPopup(context, state.debitNoteDetails, state.productNames, state.supplierNames);
          // }
        },
        child: Column(
          children: [
            // Modern Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search debit notes...', // Updated hint text
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[900], // Dark fill
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                onChanged: (query) {
                  // Assuming the search method name is searchDebitNotes
                  context.read<DebitnoteCubit>().searchDebitnoteCubits(query);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<DebitnoteCubit, DebitnoteCubitState>(
                builder: (context, state) {
                  if (state is DebitnoteCubitLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white), // Themed
                    );
                  } else if (state is DebitnoteCubitError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent), // Themed
                      ),
                    );
                  } else if (state is DebitnoteCubitLoaded) {
                    // Use a more descriptive name
                    final debitNotes = state.filteredInvoices;
                    if (debitNotes.isEmpty) {
                      return Center(
                        child: Text(
                          'No debit notes found', // Updated empty message
                          style: TextStyle(color: Colors.grey[400]), // Themed
                        ),
                      );
                    }
                    // Use ListView.separated with the custom card
                    return RefreshIndicator(
                      onRefresh: () async {
                        // Assuming the method to refresh is fetchDebitNotes
                        await context.read<DebitnoteCubit>().fetchDebitnoteCubits();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: debitNotes.length,
                        separatorBuilder: (context, index) => const Gap(8), // Consistent spacing
                        itemBuilder: (context, index) {
                          final debitNote = debitNotes[index];
                          // Use the new custom card widget
                          return _DebitNoteCard(debitNote: debitNote);
                        },
                      ),
                    );
                  }
                  // Default/fallback state
                  return Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey[400]),
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
}

// --- Custom Card Widget for Debit Note List ---
class _DebitNoteCard extends StatelessWidget {
  final DebitNote debitNote;

  const _DebitNoteCard({required this.debitNote});

  // Helper to get status color - handles null
  Color _getStatusColor(String? status, double opacity) {
    switch (status) {
      case 'Paid':
        return Colors.green.withOpacity(opacity);
      case 'Unpaid':
        return Colors.red.withOpacity(opacity);
      case 'Partial': // Assuming 'Partial' might be a status
        return Colors.orange.withOpacity(opacity);
      default:
        return Colors.grey.withOpacity(opacity); // Default for null or unknown
    }
  }

   // Helper to get status text color - handles null
  Color _getStatusTextColor(String? status) {
     switch (status) {
      case 'Paid':
        return Colors.green[300]!;
      case 'Unpaid':
        return Colors.red[300]!;
      case 'Partial':
        return Colors.orange[300]!;
      default:
        return Colors.grey[300]!;
    }
  }


  @override
  Widget build(BuildContext context) {
    final BorderRadius cardBorderRadius = BorderRadius.circular(12);
    final Color hoverColor = Colors.white.withOpacity(0.05);
    final Color highlightColor = Colors.white.withOpacity(0.08);
    final Color splashColor = Colors.white.withOpacity(0.04);
    final String statusText = debitNote.paymentStatus ?? 'Unknown'; // Handle null status

    return InkWell( // Use InkWell for interaction
      onTap: () {
        // Fetch specific details when card is tapped
        context
            .read<DebitnoteCubit>()
            .fetchDebitnoteCubitById(debitNote.debitNoteId);
      },
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      borderRadius: cardBorderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900], // Dark card background
          borderRadius: cardBorderRadius,
          border: Border.all(color: Colors.grey[800]!), // Subtle border
        ),
        padding: const EdgeInsets.all(16), // Internal padding
        child: Column( // Use Column for multi-line info
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Debit Note ID
                Text(
                  'DN-${debitNote.debitNoteId}', // Use DN prefix
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Use helper for color based on status
                    color: _getStatusColor(debitNote.paymentStatus, 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      // Use helper for text color based on status
                      color: _getStatusTextColor(debitNote.paymentStatus),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12), // Consistent spacing
            // Date and Amount Row
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                const Gap(4),
                Text(
                  debitNote.invoiceDate.toString().split(' ')[0], // Display date
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const Spacer(), // Pushes amount to the right
                Text(
                  // Format amount appropriately
                  '\$${debitNote.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Modern Debit Note Details Popup ---
void _showDebitNoteDetailsPopup( // Renamed function
  BuildContext context,
  DebitNote debitNote, // Use DebitNote object
  Map<int, String> productNames,
  Map<int, String> supplierNames,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog( // Use Dialog
        backgroundColor: Colors.grey[900], // Dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        insetPadding: const EdgeInsets.all(16), // Padding around dialog
        child: SingleChildScrollView( // Allow content to scroll
          child: Padding(
            padding: const EdgeInsets.all(20), // Inner padding
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Debit Note Details', // Updated Title
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const Divider(color: Colors.grey), // Divider
                const Gap(16),

                // --- Basic Info ---
                _DetailRow(
                  label: 'Debit Note #',
                  value: debitNote.debitNoteId.toString(),
                ),
                _DetailRow(
                  label: 'Date',
                  value: debitNote.invoiceDate.toString().split(' ')[0],
                ),
                 _DetailRow(
                  label: 'Supplier',
                  value: supplierNames[debitNote.supplierId] ??
                      'Supplier #${debitNote.supplierId}',
                ),
                _DetailRow(
                  label: 'Journal Entry ID',
                  value: debitNote.journalEntryID.toString(),
                ),
                const Gap(16),

                // --- Items Section ---
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const Gap(8),
                Container( // Container for table background/border
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table( // Using Table for structured item display
                    columnWidths: const { // Adjust column widths as needed
                      0: FlexColumnWidth(2.5), // Name
                      1: FlexColumnWidth(1),   // Price
                      2: FlexColumnWidth(0.8), // Qty
                      3: FlexColumnWidth(1),   // Discount
                      4: FlexColumnWidth(1),   // Tax
                      5: FlexColumnWidth(1.2), // Subtotal
                    },
                    children: [
                      // Table Header using helper widget
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        children: [
                          _TableHeaderCell('Name'),
                          _TableHeaderCell('Price'),
                          _TableHeaderCell('Qty'),
                          _TableHeaderCell('Discount'),
                          _TableHeaderCell('Tax'),
                          _TableHeaderCell('Subtotal'),
                        ],
                      ),
                      // Table Rows using helper widget
                      ...debitNote.debitNoteItemsDto.map((item) {
                        return TableRow(
                          children: [
                            _TableCell(productNames[item.productId] ?? 'Product #${item.productId}'),
                            _TableCell('\$${item.unitPrice.toStringAsFixed(2)}'),
                            _TableCell('${item.quantity}'),
                            _TableCell('\$${item.discount.toStringAsFixed(2)}'),
                            _TableCell('\$${item.tax.toStringAsFixed(2)}'),
                            _TableCell('\$${item.totalPrice.toStringAsFixed(2)}'),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const Gap(16),

                // --- Totals Section ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _TotalRow( // Using helper widget
                        label: 'Total Amount', // Adjusted label
                        value: '\$${debitNote.totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      const Gap(8),
                      // Status Badge Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status:', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _DebitNoteCard(debitNote: debitNote)._getStatusColor(debitNote.paymentStatus, 0.2), // Reuse logic
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              debitNote.paymentStatus ?? 'Unknown',
                              style: TextStyle(
                                color: _DebitNoteCard(debitNote: debitNote)._getStatusTextColor(debitNote.paymentStatus), // Reuse logic
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // --- Notes Section ---
                Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const Gap(8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Handle null notes
                    debitNote.notes?.isNotEmpty == true ? debitNote.notes! : 'No notes provided.',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ),
                const Gap(24),

                // --- Action Buttons ---
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
                   children: [
                     OutlinedButton( // Just a close button for now
                       style: OutlinedButton.styleFrom(
                         foregroundColor: Colors.white,
                         side: const BorderSide(color: Colors.grey),
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       onPressed: () => Navigator.pop(context),
                       child: const Text('Close'),
                     ),
                     // Add ElevatedButton for 'Print PDF' here if needed, similar to previous examples
                   ],
                 ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


// --- Helper Widgets (Ensure these are defined or imported) ---

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Adjust as needed
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  //final TextAlign textAlign;

  const _TableHeaderCell(this.text,/* {this.textAlign = TextAlign.left}*/);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        //textAlign: textAlign,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13, // Slightly smaller header font
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  //final TextAlign textAlign;

  const _TableCell(this.text, /*{this.textAlign = TextAlign.left}*/);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
         //textAlign: textAlign,
        style: TextStyle(color: Colors.grey[300], fontSize: 13), // Slightly smaller cell font
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isBold ? 16 : 14, // Slightly larger if bold
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}