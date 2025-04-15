import 'package:erp/Core/widgets/genricori_dialogbox.dart';
import 'package:erp/features/auth/data/entities/sales/salesInvoice_entity.dart';
import 'package:erp/features/auth/logic/sales/salesInvoice_cubit.dart';
import 'package:erp/features/auth/presentation/sales/sendata/salesinvoicecreate_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SalesInvoiceScreen extends StatefulWidget {
  const SalesInvoiceScreen({super.key});

  @override
  State<SalesInvoiceScreen> createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  @override
  void initState() {
    context.read<SalesInvoiceCubit>().fetchSalesInvoices();
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
          'Sales Invoices',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Simple, clear add icon
            color: Colors.white,         // Ensure icon color matches theme
            tooltip: 'Create New Invoice', // Accessibility feature
            onPressed: () {
              // Navigate to the Sales Invoice Create Screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  // Replace SalesInvoiceCreateScreen with your actual create screen widget
                  builder: (context) => const SalesInvoiceScreencreate(),
                ),
              );
              // Optionally, you could use pushNamed if using named routes
              // Navigator.of(context).pushNamed('/create-sales-invoice');
            },
          ),
          const SizedBox(width: 8), // Optional padding from the edge
        ],
      ),
      body: BlocListener<SalesInvoiceCubit, SalesInvoiceState>(
        listener: (context, state) {
          if (state is SalesInvoiceLoaded && state.selectedInvoice != null) {
            context.read<SalesInvoiceCubit>().resetSelectedInvoice();
            _showInvoiceDetailsPopup(
              context,
              state.selectedInvoice!,
              state.productNames,
              state.customerNames,
            );
          }
        },
        child: Column(
          children: [
            // Modern Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search invoices...',
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
                  context.read<SalesInvoiceCubit>().searchSalesInvoices(query);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SalesInvoiceCubit, SalesInvoiceState>(
                builder: (context, state) {
                  if (state is SalesInvoiceLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (state is SalesInvoiceError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is SalesInvoiceLoaded) {
                    final invoices = state.filteredInvoices;
                    if (invoices.isEmpty) {
                      return Center(
                        child: Text(
                          'No invoices found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<SalesInvoiceCubit>().fetchSalesInvoices();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: invoices.length,
                        separatorBuilder: (context, index) => const Gap(8),
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return _SalesInvoiceCard(invoice: invoice);
                        },
                      ),
                    );
                  }
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

  void _showInvoiceDetailsPopup(
    BuildContext context,
    SalesInvoice invoice,
    Map<int, String> productNames,
    Map<int, String> customerNames,
  ) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    OrientationAwareDialog.show(
      context: context,
      title: 'Invoice #${invoice.invoiceId}',
      subtitle: 'Customer: ${customerNames[invoice.customerID]}',
      statusWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusBackgroundColor(invoice.paymentStatus),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          invoice.paymentStatus.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      tabCount: 2,
      tabLabels: const ['Items', 'Payments'],
      tabViews: [
        SingleChildScrollView(
            child: _buildItemsTab(invoice, productNames, isLandscape)),
        SingleChildScrollView(child: _buildPaymentsTab(invoice, isLandscape)),
      ],
      fixedHeight:
          isLandscape ? media.size.height * 0.7 : media.size.height * 0.75,
      headerIcon: Icons.receipt,
      contentPadding: const EdgeInsets.all(16),
      horizontalInsetPercentage: 0.04,
      scrollPhysics: const ClampingScrollPhysics(),
      backgroundColor: Colors.grey[900],
      headerColor: Colors.black,
    );
  }

  Widget _buildItemsTab(
      SalesInvoice invoice, Map<int, String> productNames, bool isLandscape) {
    final items = invoice.invoiceItems ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                  'Subtotal', '\$${invoice.total.toStringAsFixed(2)}'),
              _buildSummaryRow('Tax', '\$${invoice.tax.toStringAsFixed(2)}'),
              _buildSummaryRow(
                  'Discount', '\$${invoice.discount.toStringAsFixed(2)}'),
              const Divider(color: Colors.grey),
              _buildSummaryRow(
                'Total',
                '\$${(invoice.total + invoice.tax - invoice.discount).toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
        const Gap(16),

        // Items List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Gap(8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productNames[item.productId] ??
                              'Product #${item.productId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '${item.quantity} × \$${item.unitPrice}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentsTab(SalesInvoice invoice, bool isLandscape) {
    final payments = invoice.clientPayments ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: payments.length,
          separatorBuilder: (context, index) => const Gap(8),
          itemBuilder: (context, index) {
            final payment = payments[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.green),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment #${payment.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          payment.paymentMethod,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        payment.createdDate.toString().split(' ')[0],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.withOpacity(0.2);
      case 'unpaid':
        return Colors.red.withOpacity(0.2);
      case 'partial':
        return Colors.orange.withOpacity(0.2);
      case 'overdue':
        return Colors.deepOrange.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesInvoiceCard extends StatelessWidget {
  final SalesInvoice invoice;

  const _SalesInvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context
            .read<SalesInvoiceCubit>()
            .fetchSalesInvoiceById(invoice.invoiceId);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
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
                  'INV-${invoice.invoiceId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(invoice.paymentStatus),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    invoice.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusTextColor(invoice.paymentStatus),
                      fontWeight: FontWeight.bold,
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
                  '\$${invoice.total.toStringAsFixed(2)}',
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

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.withOpacity(0.2);
      case 'unpaid':
        return Colors.red.withOpacity(0.2);
      case 'partial':
        return Colors.orange.withOpacity(0.2);
      case 'overdue':
        return Colors.deepOrange.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green[300]!;
      case 'unpaid':
        return Colors.red[300]!;
      case 'partial':
        return Colors.orange[300]!;
      case 'overdue':
        return Colors.deepOrange[300]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
