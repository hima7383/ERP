import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/purchase/debit_note.dart';
import 'package:erp/features/auth/logic/purchase/debitnote_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class DebitNoteScreen extends StatefulWidget {
  const DebitNoteScreen({super.key});

  @override
  State<DebitNoteScreen> createState() => _DebitNoteScreenState();
}

class _DebitNoteScreenState extends State<DebitNoteScreen> {
  @override
  void initState() {
    context.read<DebitnoteCubit>().fetchDebitnoteCubits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        title: const Text(
          'Debit Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<DebitnoteCubit, DebitnoteCubitState>(
        listener: (context, state) {
          if (state is DebitnoteCubitLoaded && state.selectedInvoice != null) {
            _showDebitNoteDetailsPopup(context, state.selectedInvoice!,
                state.productNames, state.supplierNames);
            context.read<DebitnoteCubit>().resetSelectedInvoice();
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DebitnoteCubitState state) {
    if (state is DebitnoteCubitLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    } else if (state is DebitnoteCubitError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is DebitnoteCubitLoadingById ||
        state is DebitnoteCubitLoaded) {
      final debitNotes = (state is DebitnoteCubitLoaded)
          ? state.filteredInvoices
          : (state as DebitnoteCubitLoadingById).previousState
                  is DebitnoteCubitLoaded
              ? (state.previousState as DebitnoteCubitLoaded).filteredInvoices
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
                    context.read<DebitnoteCubit>().searchDebitnoteCubits(query);
                  },
                ),
              ),
              Expanded(
                child: debitNotes.isEmpty
                    ? Center(
                        child: Text(
                          'No debit notes found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<DebitnoteCubit>()
                              .fetchDebitnoteCubits();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: debitNotes.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final debitNote = debitNotes[index];
                            return _DebitNoteCard(debitNote: debitNote);
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is DebitnoteCubitLoadingById) const ModernLoadingOverlay(),
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

  void _showDebitNoteDetailsPopup(
    BuildContext context,
    DebitNote debitNote,
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
                        'Debit Note Details',
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
                        ...debitNote.debitNoteItemsDto.map((item) {
                          return TableRow(
                            children: [
                              _TableCell(
                                productNames[item.productId] ??
                                    'Product #${item.productId}',
                              ),
                              _TableCell(
                                  '\$${item.unitPrice.toStringAsFixed(2)}'),
                              _TableCell('${item.quantity}'),
                              _TableCell(
                                  '\$${item.totalPrice.toStringAsFixed(2)}'),
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
                          label: 'Total Amount',
                          value:
                              '\$${debitNote.totalAmount.toStringAsFixed(2)}',
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
                                color: _getStatusColor(
                                    debitNote.paymentStatus, 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                debitNote.paymentStatus ?? 'Unknown',
                                style: TextStyle(
                                  color: _getStatusTextColor(
                                      debitNote.paymentStatus),
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
                      debitNote.notes?.isNotEmpty == true
                          ? debitNote.notes!
                          : 'No notes provided',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                  const Gap(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
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

  Color _getStatusColor(String? status, double opacity) {
    switch (status) {
      case 'Paid':
        return Colors.green.withOpacity(opacity);
      case 'Unpaid':
        return Colors.red.withOpacity(opacity);
      case 'Partial':
        return Colors.orange.withOpacity(opacity);
      default:
        return Colors.grey.withOpacity(opacity);
    }
  }

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
}

class _DebitNoteCard extends StatelessWidget {
  final DebitNote debitNote;

  const _DebitNoteCard({required this.debitNote});

  @override
  Widget build(BuildContext context) {
    final BorderRadius cardBorderRadius = BorderRadius.circular(12);
    final Color hoverColor = Colors.white.withOpacity(0.05);
    final Color highlightColor = Colors.white.withOpacity(0.08);
    final Color splashColor = Colors.white.withOpacity(0.04);

    return InkWell(
      onTap: () {
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
                  'DN-${debitNote.debitNoteId}',
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
                    color: _getStatusColor(debitNote.paymentStatus, 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    debitNote.paymentStatus ?? 'Unknown',
                    style: TextStyle(
                      color: _getStatusTextColor(debitNote.paymentStatus),
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
                  debitNote.invoiceDate.toString().split(' ')[0],
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const Spacer(),
                Text(
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

  Color _getStatusColor(String? status, double opacity) {
    switch (status) {
      case 'Paid':
        return Colors.green.withOpacity(opacity);
      case 'Unpaid':
        return Colors.red.withOpacity(opacity);
      case 'Partial':
        return Colors.orange.withOpacity(opacity);
      default:
        return Colors.grey.withOpacity(opacity);
    }
  }

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
        style: const TextStyle(
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
