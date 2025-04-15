import 'package:erp/features/auth/data/entities/sales/quotation_entity.dart';
import 'package:erp/features/auth/logic/sales/quotation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart'; // Import Gap

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  @override
  void initState() {
    // Assuming initial fetch is handled by the Cubit or elsewhere.
    // If not, add: context.read<QuotationCubit>().fetchQuotations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        title: const Text(
          // Modern AppBar title style
          'Quotations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false, // Left-align title
        iconTheme: const IconThemeData(color: Colors.white), // White icons
      ),
      body: BlocListener<QuotationCubit, QuotationState>(
        listener: (context, state) {
          if (state is QuotationLoaded && state.selectedQuotation != null) {
            context.read<QuotationCubit>().resetSelectedQuotation();
            // Show the modernized popup
            _showQuotationDetailsPopup(context, state.selectedQuotation!,
                state.productNames, state.customerNames);
            // Reset selection immediately after triggering popup to prevent re-showing
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
                  hintText: 'Search quotations...', // Updated hint text
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
                  context.read<QuotationCubit>().searchQuotations(query);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<QuotationCubit, QuotationState>(
                builder: (context, state) {
                  if (state is QuotationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white), // Themed
                    );
                  } else if (state is QuotationError) {
                    return Center(
                      child: Text(
                        state.message,
                        style:
                            const TextStyle(color: Colors.redAccent), // Themed
                      ),
                    );
                  } else if (state is QuotationLoaded) {
                    final quotations = state.filteredQuotations;
                    if (quotations.isEmpty) {
                      return Center(
                        child: Text(
                          'No quotations found',
                          style: TextStyle(color: Colors.grey[400]), // Themed
                        ),
                      );
                    }
                    // Use ListView.separated with the custom card
                    return RefreshIndicator(
                      onRefresh: () async {
                        // Trigger a refresh action in the cubit
                        context.read<QuotationCubit>().fetchQuotations();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: quotations.length,
                        separatorBuilder: (context, index) => const Gap(8),
                        itemBuilder: (context, index) {
                          final quotation = quotations[index];
                          final customerName =
                              state.customerNames[quotation.customerId] ??
                                  'Customer ${quotation.customerId}';
                          // Use the new custom card widget
                          return _QuotationCard(
                            quotation: quotation,
                            customerName: customerName,
                          );
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

  // --- Modern Quotation Details Popup (replaces OrientationAwareDialog) ---
  void _showQuotationDetailsPopup(
    BuildContext context,
    Quotation quotation,
    Map<int, String> productNames,
    Map<int, String> customerNames,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final customerName = customerNames[quotation.customerId] ??
        'Customer ${quotation.customerId}';

    showDialog(
        context: context,
        builder: (context) {
          return DefaultTabController(
            // Use TabController for tabs
            length: 2, // Number of tabs: Details, Items
            child: Dialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SizedBox(
                width: screenWidth < 600 ? screenWidth * 0.9 : 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Styled Header ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon instead of Avatar for Quotation maybe?
                          Icon(Icons.receipt_long_outlined,
                              color: Colors.blueAccent, size: 32),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quotation #${quotation.quotationId}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const Gap(2),
                                Text(
                                  customerName,
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Status Badge in Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: quotation.statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: quotation.statusColor, width: 1),
                            ),
                            child: Text(
                              quotation.statusText.toUpperCase(),
                              style: TextStyle(
                                  color: quotation.statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Gap(8), // Gap before close button
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),

                    // --- Styled TabBar ---
                    Container(
                      color: Colors.grey[850],
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[400],
                        indicatorColor: Colors.blueAccent,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: 'Details'),
                          Tab(text: 'Items'),
                        ],
                      ),
                    ),

                    // --- Tab Content ---
                    Flexible(
                      // Allow TabBarView to fill available space
                      child: Container(
                        // Constrain height if needed, or let Flexible handle it
                        // height: MediaQuery.of(context).size.height * 0.5,
                        child: TabBarView(
                          children: [
                            // Use helper methods passing modern widgets
                            _buildDetailsTab(quotation),
                            _buildItemsTab(quotation, productNames),
                          ],
                        ),
                      ),
                    ),
                    // No separate actions needed as Close is in header
                  ],
                ),
              ),
            ),
          );
        });
  }

  // --- Popup Tab Builders using modern widgets ---

  Widget _buildDetailsTab(Quotation quotation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
              label: 'Quote Date',
              value: quotation.quoteDate.toString().split(' ')[0]),
          _DetailRow(
              label: 'Expiry Date',
              value: quotation.expiryDate.toString().split(' ')[0]),
          _DetailRow(label: 'Status', value: quotation.statusText),
          _DetailRow(
              label: 'Invoice ID',
              value: quotation.invoiceId?.toString() ?? 'Not Invoiced'),
          const Gap(10),
          _DetailRow(
              label: 'Subtotal',
              value: '\$${quotation.grandTotal.toStringAsFixed(2)}'),
          _DetailRow(
              label: 'Discount',
              value:
                  '${(quotation.discount * 100).toStringAsFixed(1)}% (-\$${quotation.discount.toStringAsFixed(2)})'),
          _DetailRow(
              label: 'Tax',
              value: '\$${quotation.discount.toStringAsFixed(2)}'),
          const Divider(
            color: Colors.grey,
            height: 20,
          ),
          _TotalRow(
              label: 'Grand Total',
              value: '\$${quotation.grandTotal.toStringAsFixed(2)}',
              isBold: true),
          const Gap(16),
          // Add Notes section if available in Quotation entity
          // if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
          //   Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          //   const Gap(8),
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: Colors.grey[800],
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Text(quotation.notes!, style: TextStyle(color: Colors.grey[300])),
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _buildItemsTab(Quotation quotation, Map<int, String> productNames) {
    final items = quotation.items ?? [];
    if (items.isEmpty) {
      return Center(
          child: Text('No items found in this quotation.',
              style: TextStyle(color: Colors.grey[400])));
    }
    // Use ListView.separated for items list within the tab
    return ListView.separated(
      padding: const EdgeInsets.all(16), // Padding for the list within the tab
      itemCount: items.length,
      separatorBuilder: (context, index) => const Gap(8),
      itemBuilder: (context, index) {
        final item = items[index];
        final productName =
            productNames[item.productId] ?? 'Product ${item.productId}';
        // Use a styled Container for each item
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[800], // Item background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    const Gap(4),
                    Text(
                      'Qty: ${item.quantity} @ \$${item.unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              // Price details on the right
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Custom Card Widget for Quotation List ---
class _QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final String customerName;

  const _QuotationCard({required this.quotation, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final BorderRadius cardBorderRadius = BorderRadius.circular(12);
    final Color hoverColor = Colors.white.withOpacity(0.05);
    final Color highlightColor = Colors.white.withOpacity(0.08);
    final Color splashColor = Colors.white.withOpacity(0.04);

    return InkWell(
      onTap: () {
        context
            .read<QuotationCubit>()
            .fetchQuotationById(quotation.quotationId);
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
                // ID and Customer Name
                Expanded(
                  // Allow text to wrap or ellipsis
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QT-${quotation.quotationId}', // Use QT prefix
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      const Gap(2),
                      Text(
                        customerName,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Gap(8), // Add gap before status badge
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: quotation.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quotation.statusText.toUpperCase(),
                    style: TextStyle(
                      color: quotation.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Date and Amount Row
            Row(
              children: [
                Icon(Icons.hourglass_bottom,
                    size: 14, color: Colors.grey[500]), // Expiry Icon
                const Gap(4),
                Text(
                  'Expires: ${quotation.expiryDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '\$${quotation.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets (Ensure these are defined correctly) ---

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
            width: 100, // Consistent label width
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
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

// Include _TotalRow if needed (used in Details tab)
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
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
