import 'package:erp/Core/widgets/genricori_dialogbox.dart';
import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/sales/recuringinvoice_entity.dart';
import 'package:erp/features/auth/logic/sales/recuringinvoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class RecurringInvoiceScreen extends StatefulWidget {
  const RecurringInvoiceScreen({super.key});

  @override
  State<RecurringInvoiceScreen> createState() => _RecurringInvoiceScreenState();
}

class _RecurringInvoiceScreenState extends State<RecurringInvoiceScreen> {
  @override
  void initState() {
    context.read<RecurringInvoiceCubit>().fetchRecurringInvoices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecurringInvoiceCubit, RecurringInvoiceState>(
      listener: (context, state) {
        if (state is RecurringInvoiceError) {
          Center(
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
                            onPressed: () => context.read<RecurringInvoiceCubit>().fetchRecurringInvoices(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
        }
        if (state is RecurringInvoiceLoaded && state.selectedInvoice != null) {
          _showInvoiceDetailsPopup(
            context,
            state.selectedInvoice!,
            state.productNames,
            state.customerNames,
          );
          context.read<RecurringInvoiceCubit>().resetSelectedInvoice();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            title: const Text(
              'Recurring Invoices',
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

  Widget _buildBody(BuildContext context, RecurringInvoiceState state) {
    if (state is RecurringInvoiceLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (state is RecurringInvoiceError) {
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
                            onPressed: () => context.read<RecurringInvoiceCubit>().fetchRecurringInvoices(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
    } else if (state is RecurringInvoiceLoadingById ||
        state is RecurringInvoiceLoaded) {
      final invoices = (state is RecurringInvoiceLoaded)
          ? state.filteredInvoices
          : (state as RecurringInvoiceLoadingById).previousState
                  is RecurringInvoiceLoaded
              ? (state.previousState as RecurringInvoiceLoaded).filteredInvoices
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
                    hintText: 'Search by ID, Customer, or Amount',
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
                        .read<RecurringInvoiceCubit>()
                        .searchRecurringInvoices(query);
                  },
                ),
              ),
              Expanded(
                child: invoices.isEmpty
                    ? Center(
                        child: Text(
                          'No recurring invoices found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<RecurringInvoiceCubit>()
                              .fetchRecurringInvoices();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: invoices.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            final customerName =
                                (state is RecurringInvoiceLoaded)
                                    ? state.customerNames[invoice.customerId] ??
                                        'Customer ${invoice.customerId}'
                                    : 'Loading...';

                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                title: Text(
                                  invoice.subscriptionName ??
                                      'Invoice #${invoice.recurringInvoiceId}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customerName,
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Next: ${invoice.nextInvoiceDate.toString().split(' ')[0]}',
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${invoice.total.toStringAsFixed(2)}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: invoice.isActive
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        invoice.isActive
                                            ? 'Active'
                                            : 'Inactive',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  context
                                      .read<RecurringInvoiceCubit>()
                                      .fetchRecurringInvoiceById(
                                          invoice.recurringInvoiceId);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is RecurringInvoiceLoadingById)
            const ModernLoadingOverlay(msg: "Recuring Invoice"),
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

  void _showInvoiceDetailsPopup(
    BuildContext context,
    RecurringInvoice invoice,
    Map<int, String> productNames,
    Map<int, String> customerNames,
  ) {
    final customerName =
        customerNames[invoice.customerId] ?? 'Customer ${invoice.customerId}';

    OrientationAwareDialog.show(
      context: context,
      title: invoice.subscriptionName ??
          'Recurring Invoice #${invoice.recurringInvoiceId}',
      subtitle: customerName,
      statusWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: invoice.isActive ? Colors.green[800] : Colors.red[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          invoice.isActive ? 'ACTIVE' : 'INACTIVE',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      tabCount: 2,
      tabLabels: const ['Details', 'Items'],
      tabViews: [
        _buildDetailsTab(invoice),
        _buildItemsTab(invoice, productNames),
      ],
      fixedHeight:
          400, // Added from our previous enhancement // 5% horizontal padding
    );
  }

  Widget _buildDetailsTab(RecurringInvoice invoice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              'Start Date', invoice.startDate.toString().split(' ')[0]),
          _buildDetailRow('Next Invoice Date',
              invoice.nextInvoiceDate.toString().split(' ')[0]),
          _buildDetailRow('Frequency', _getFrequencyText(invoice.frequency)),
          _buildDetailRow('Issue Every',
              '${invoice.issueEvery} ${invoice.issueEvery == 1 ? 'time' : 'times'}'),
          _buildDetailRow(
              'Occurrences',
              invoice.occurrences == 0
                  ? 'Unlimited'
                  : invoice.occurrences.toString()),
          _buildDetailRow('Days Before', invoice.issueInvoiceBefore.toString()),
          _buildDetailRow('Total', '\$${invoice.total.toStringAsFixed(2)}'),
          _buildDetailRow(
              'Discount', '${(invoice.discount * 100).toStringAsFixed(2)}%'),
          _buildDetailRow('Send Email', invoice.sendEmail ? 'Yes' : 'No'),
          _buildDetailRow(
              'Auto Payment', invoice.automaticPayment ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildItemsTab(
      RecurringInvoice invoice, Map<int, String> productNames) {
    final items = invoice.items ?? [];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Items (${items.length})',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: Colors.grey[800],
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: ListTile(
                  title: Text(
                    productNames[item.productId] ?? 'Product ${item.productId}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qty: ${item.quantity}',
                          style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(height: 4),
                      Text('\$${item.unitPrice} each',
                          style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                  trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText(int frequency) {
    switch (frequency) {
      case 1:
        return 'Daily';
      case 2:
        return 'Weekly';
      case 3:
        return 'Monthly';
      case 4:
        return 'Quarterly';
      case 5:
        return 'Yearly';
      default:
        return 'Custom';
    }
  }
}
