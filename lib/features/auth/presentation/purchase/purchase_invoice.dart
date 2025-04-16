import 'dart:typed_data';
import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp/features/auth/data/entities/purchase/purchase_invoices.dart';
import 'package:erp/features/auth/logic/purchase/purchase_cubit.dart';
import 'package:gap/gap.dart';

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  @override
  void initState() {
    context.read<PurchaseInvoiceCubit>().fetchPurchaseInvoices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseInvoiceCubit, PurchaseInvoiceState>(
      listener: (context, state) {
        if (state is PurchaseInvoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is PurchaseInvoiceLoaded && state.selectedInvoice != null) {
          _showInvoiceDetailsPopup(context, state.selectedInvoice!,
              state.productNames, state.supplierNames);
          context.read<PurchaseInvoiceCubit>().resetSelectedInvoice();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            title: const Text(
              'Purchase Invoices',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PurchaseInvoiceState state) {
    if (state is PurchaseInvoiceLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    } else if (state is PurchaseInvoiceError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is PurchaseInvoiceLoadingById ||
        state is PurchaseInvoiceLoaded) {
      final invoices = (state is PurchaseInvoiceLoaded)
          ? state.filteredInvoices
          : (state as PurchaseInvoiceLoadingById).previousState
                  is PurchaseInvoiceLoaded
              ? (state.previousState as PurchaseInvoiceLoaded).filteredInvoices
              : [];

      return Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, Amount, Status, or Date',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[900],
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
                    context
                        .read<PurchaseInvoiceCubit>()
                        .searchPurchaseInvoices(query);
                  },
                ),
              ),
              Expanded(
                child: invoices.isEmpty
                    ? Center(
                        child: Text(
                          'No purchase invoices found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<PurchaseInvoiceCubit>()
                              .fetchPurchaseInvoices();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: invoices.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            return _InvoiceCard(invoice: invoice);
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is PurchaseInvoiceLoadingById) const ModernLoadingOverlay(),
        ],
      );
    }
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  Future<Uint8List> _generateInvoicePdf(
    PurchaseInvoice invoice,
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
              pw.Text(
                'Invoice #${invoice.purchaseInvoiceId}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${invoice.invoiceDate.toString().split(' ')[0]}',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Supplier Name: ${supplierNames[invoice.supplierId] ?? 'Supplier #${invoice.supplierId}'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Journal Entry ID: ${invoice.journalEntryID}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Items',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
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
                data: invoice.items.map((item) {
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
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${invoice.totalAmount}',
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
                    invoice.paymentStatus,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: invoice.paymentStatus == 'Paid'
                          ? PdfColors.green
                          : invoice.paymentStatus == 'Unpaid'
                              ? PdfColors.red
                              : PdfColors.orange,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Notes:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                invoice.notes,
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _showInvoiceDetailsPopup(
    BuildContext context,
    PurchaseInvoice invoice,
    Map<int, String> productNames,
    Map<int, String> supplierNames,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice Details',
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
                  _DetailRow(
                    label: 'Invoice #',
                    value: invoice.purchaseInvoiceId.toString(),
                  ),
                  _DetailRow(
                    label: 'Date',
                    value: invoice.invoiceDate.toString().split(' ')[0],
                  ),
                  const Gap(16),
                  _DetailRow(
                    label: 'Supplier',
                    value: supplierNames[invoice.supplierId] ??
                        'Supplier #${invoice.supplierId}',
                  ),
                  _DetailRow(
                    label: 'Journal Entry ID',
                    value: invoice.journalEntryID.toString(),
                  ),
                  const Gap(16),
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(2.3),
                      },
                      children: [
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
                            _TableHeaderCell('Subtotal'),
                          ],
                        ),
                        ...invoice.items.map((item) {
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _TotalRow(
                          label: 'Total',
                          value: '\$${invoice.totalAmount}',
                          isBold: true,
                        ),
                        const Gap(8),
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
                                color: invoice.paymentStatus == 'Paid'
                                    ? Colors.green.withOpacity(0.2)
                                    : invoice.paymentStatus == 'Unpaid'
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                invoice.paymentStatus,
                                style: TextStyle(
                                  color: invoice.paymentStatus == 'Paid'
                                      ? Colors.green[300]
                                      : invoice.paymentStatus == 'Unpaid'
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
                      invoice.notes.isNotEmpty ? invoice.notes : 'No notes',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                  const Gap(24),
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
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final pdfBytes = await _generateInvoicePdf(
                                invoice, productNames, supplierNames);
                            final fileName =
                                'Invoice_${invoice.purchaseInvoiceId}_${invoice.invoiceDate.toString().split(' ')[0]}.pdf';
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

class _InvoiceCard extends StatelessWidget {
  final PurchaseInvoice invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final BorderRadius cardBorderRadius = BorderRadius.circular(12);
    final Color hoverColor = Colors.white.withOpacity(0.05);
    final Color highlightColor = Colors.white.withOpacity(0.08);
    final Color splashColor = Colors.white.withOpacity(0.04);

    return InkWell(
      onTap: () {
        context
            .read<PurchaseInvoiceCubit>()
            .fetchPurchaseInvoiceById(invoice.purchaseInvoiceId);
      },
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      borderRadius: cardBorderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: cardBorderRadius,
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INV-${invoice.purchaseInvoiceId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: invoice.paymentStatus == 'Paid'
                        ? Colors.green.withOpacity(0.2)
                        : invoice.paymentStatus == 'Unpaid'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    invoice.paymentStatus,
                    style: TextStyle(
                      color: invoice.paymentStatus == 'Paid'
                          ? Colors.green[300]
                          : invoice.paymentStatus == 'Unpaid'
                              ? Colors.red[300]
                              : Colors.orange[300],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                const Gap(4),
                Text(
                  invoice.invoiceDate.toString().split(' ')[0],
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '\$${invoice.totalAmount}',
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
            width: 120,
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
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
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
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[300]),
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
