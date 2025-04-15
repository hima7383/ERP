import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // The 'as pw' creates an alias
import 'package:erp/features/auth/data/entities/purchase/purchasereturn.dart';
import 'package:erp/features/auth/logic/purchase/purchaserefund_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:gap/gap.dart'; // Import Gap

// Convert to StatefulWidget for initState data fetching
class PurchaseInvoicerefundScreen extends StatefulWidget {
  const PurchaseInvoicerefundScreen({super.key});

  @override
  State<PurchaseInvoicerefundScreen> createState() =>
      _PurchaseInvoicerefundScreenState();
}

class _PurchaseInvoicerefundScreenState
    extends State<PurchaseInvoicerefundScreen> {
  @override
  void initState() {
    // Fetch data when the screen loads
    context.read<PurchaseInvoicerefundCubit>().fetchPurchaseInvoices(); // Assuming method name
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        title: const Text( // Updated AppBar Title style
          'Purchase Refunds', // More appropriate title
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false, // Left-align title
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow etc.
      ),
      body: BlocListener<PurchaseInvoicerefundCubit, PurchaseInvoicerefundState>(
        listener: (context, state) {
          if (state is PurchaseInvoicerefundLoaded &&
              state.selectedInvoice != null) {
            // Use the updated popup method
            _showRefundDetailsPopup(context, state.selectedInvoice!,
                state.productNames, state.supplierNames);
          }
        },
        child: Column(
          children: [
            // Modern Search Bar (copied from PurchaseInvoiceScreen)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white), // White input text
                decoration: InputDecoration(
                  hintText: 'Search refunds...', // Updated hint text
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[900], // Dark fill
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    borderSide: BorderSide.none, // No visible border line
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                onChanged: (query) {
                  context
                      .read<PurchaseInvoicerefundCubit>()
                      .searchPurchaseInvoices(query); // Keep search logic
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<PurchaseInvoicerefundCubit,
                  PurchaseInvoicerefundState>(
                builder: (context, state) {
                  if (state is PurchaseInvoicerefundLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white, // White loading indicator
                      ),
                    );
                  } else if (state is PurchaseInvoicerefundError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent), // Error color
                      ),
                    );
                  } else if (state is PurchaseInvoicerefundLoaded) {
                    final refunds = state.filteredInvoices; // Rename for clarity
                    if (refunds.isEmpty) {
                      return Center(
                        child: Text(
                          'No purchase refunds found', // Updated empty message
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      );
                    }
                    // Use ListView.separated with the custom card
                    return RefreshIndicator(
                      onRefresh: () async {
                        // Refresh logic (if needed)
                        context
                            .read<PurchaseInvoicerefundCubit>()
                            .fetchPurchaseInvoices(); // Fetch again
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16), // Padding for list
                        itemCount: refunds.length,
                        separatorBuilder: (context, index) => const Gap(8), // Consistent spacing
                        itemBuilder: (context, index) {
                          final refund = refunds[index];
                          // Use the new custom card widget
                          return _RefundCard(refund: refund);
                        },
                      ),
                    );
                  }
                  // Default/fallback state
                  return Center(
                    child: Text(
                      'No data found',
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

  // --- PDF Generation (Consider renaming for clarity) ---
  Future<Uint8List> _generateRefundPdf( // Renamed for clarity
    PurchaseInvoiceRefund refund,
    Map<int, String> productNames,
    Map<int, String> supplierNames,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Refund Header
              pw.Text(
                'Refund Note #${refund.purchaseInvoiceRefundId}', // Updated title
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${refund.invoiceDate.toString().split(' ')[0]}',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 16),

              // Supplier Info
              pw.Text(
                'Supplier Name: ${supplierNames[refund.supplierId] ?? 'Supplier #${refund.supplierId}'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Journal Entry ID: ${refund.journalEntryID}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 16),

              // Items Table
              pw.Text(
                'Returned Items', // Updated title
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray( // Using TableHelper for simplicity here
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                headers: ['Name', 'Unit Price', 'Qty', 'Subtotal'],
                data: refund.purchaseReturnItemsDto.map((item) { // Use correct DTO list
                  return [
                    productNames[item.productId] ??
                        'Product #${item.productId}',
                    '\$${item.unitPrice}',
                    '${item.quantity}',
                    '\$${item.totalPrice}',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),

              // Total Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Refund:', // Updated label
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${refund.totalAmount}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Payment Status:',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    refund.paymentStatus,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: refund.paymentStatus == 'Paid'
                          ? PdfColors.green
                          : refund.paymentStatus == 'Unpaid'
                              ? PdfColors.red
                              : PdfColors.orange,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Notes
              pw.Text(
                'Notes:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                refund.notes ?? "No notes", // Handle null notes
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- Modern Details Popup ---
  void _showRefundDetailsPopup( // Renamed for clarity
      BuildContext context,
      PurchaseInvoiceRefund refund, // Use Refund object
      Map<int, String> productNames,
      Map<int, String> supplierNames) {
    showDialog(
      context: context,
      builder: (context) {
        // Use Dialog for more customization options
        return Dialog(
          backgroundColor: Colors.grey[900], // Dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          insetPadding: const EdgeInsets.all(16), // Padding around the dialog
          child: SingleChildScrollView( // Make content scrollable
            child: Padding(
              padding: const EdgeInsets.all(20), // Inner padding
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content size
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row (Title + Close Button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Refund Details', // Updated Title
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
                  const Divider(color: Colors.grey),
                  const Gap(16),

                  // Refund Info using _DetailRow
                  _DetailRow(
                    label: 'Refund #',
                    value: refund.purchaseInvoiceRefundId.toString(),
                  ),
                  _DetailRow(
                    label: 'Date',
                    value: refund.invoiceDate.toString().split(' ')[0],
                  ),
                  const Gap(16),

                  // Supplier Info using _DetailRow
                  _DetailRow(
                    label: 'Supplier',
                    value: supplierNames[refund.supplierId] ??
                        'Supplier #${refund.supplierId}',
                  ),
                  _DetailRow(
                    label: 'Journal Entry ID',
                    value: refund.journalEntryID.toString(),
                  ),
                  const Gap(16),

                  // Items Table (Modern Style)
                  Text(
                    'Returned Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  Container( // Container for table background/border
                    decoration: BoxDecoration(
                      color: Colors.grey[800], // Slightly lighter background for table area
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        // Table Header
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[700], // Header background
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          children: [
                            _TableHeaderCell('Name'),
                            _TableHeaderCell('Price'),
                            _TableHeaderCell('Qty'),
                            _TableHeaderCell('Subtotal'),
                          ],
                        ),
                        // Table Rows
                        ...refund.purchaseReturnItemsDto.map((item) { // Use correct DTO list
                          return TableRow(
                            children: [
                              _TableCell(
                                productNames[item.productId] ??
                                    'Product #${item.productId}',
                              ),
                              _TableCell('\$${item.unitPrice}'),
                              _TableCell('${item.quantity}'),
                              _TableCell('\$${item.totalPrice}'),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Totals (Modern Style)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // _TotalRow( // Example if you had subtotal/tax
                        //   label: 'Subtotal',
                        //   value: '\$${refund.calculateSubtotal()}', // Example method
                        // ),
                        // const Divider(color: Colors.grey),
                        _TotalRow(
                          label: 'Total Refund',
                          value: '\$${refund.totalAmount}',
                          isBold: true,
                        ),
                        const Gap(8),
                        // Status Badge Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status:',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: refund.paymentStatus == 'Paid'
                                    ? Colors.green.withOpacity(0.2)
                                    : refund.paymentStatus == 'Unpaid'
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                refund.paymentStatus,
                                style: TextStyle(
                                  color: refund.paymentStatus == 'Paid'
                                      ? Colors.green[300]
                                      : refund.paymentStatus == 'Unpaid'
                                          ? Colors.red[300]
                                          : Colors.orange[300],
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

                  // Notes (Modern Style)
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      refund.notes?.isNotEmpty == true ? refund.notes! : 'No notes',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                  const Gap(24),

                  // Action Buttons (Modern Style)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800], // Accent color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            // Use the renamed PDF function
                            final pdfBytes = await _generateRefundPdf(
                                refund, productNames, supplierNames);
                            final fileName =
                                'Refund_${refund.purchaseInvoiceRefundId}_' // Updated filename
                                '${refund.invoiceDate.toString().split(' ')[0]}.pdf';
                            await Printing.layoutPdf(
                              onLayout: (_) => pdfBytes,
                              name: fileName,
                            );
                          },
                          child: const Text('Print PDF'),
                        ),
                      ),
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
}

// --- Custom Card Widget for Refunds ---
class _RefundCard extends StatelessWidget {
  final PurchaseInvoiceRefund refund; // Use Refund object

  const _RefundCard({required this.refund});

  @override
  Widget build(BuildContext context) {
    final BorderRadius cardBorderRadius = BorderRadius.circular(12);
    final Color hoverColor = Colors.white.withOpacity(0.05);
    final Color highlightColor = Colors.white.withOpacity(0.08);
    final Color splashColor = Colors.white.withOpacity(0.04);

    return InkWell( // Use InkWell for hover/tap effects
      onTap: () {
        // Fetch specific refund details on tap
        context
            .read<PurchaseInvoicerefundCubit>()
            .fetchPurchaseInvoicerefundById(refund.purchaseInvoiceRefundId);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REF-${refund.purchaseInvoiceRefundId}', // Use REF prefix
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                // Status Badge (copied style)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: refund.paymentStatus == 'Paid'
                        ? Colors.green.withOpacity(0.2)
                        : refund.paymentStatus == 'Unpaid'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    refund.paymentStatus,
                    style: TextStyle(
                      color: refund.paymentStatus == 'Paid'
                          ? Colors.green[300]
                          : refund.paymentStatus == 'Unpaid'
                              ? Colors.red[300]
                              : Colors.orange[300],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12), // Consistent spacing
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                const Gap(4),
                Text(
                  refund.invoiceDate.toString().split(' ')[0], // Display date
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const Spacer(), // Pushes amount to the right
                Text(
                  '\$${refund.totalAmount}', // Display total amount
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


// --- Helper Widgets for Popup (Copied from PurchaseInvoiceScreen) ---

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
            width: 120, // Consistent label width
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          const Gap(8),
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
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12), // Padding within header cells
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white, // Header text color
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;

  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12), // Padding within table cells
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[300]), // Table data text color
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
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}