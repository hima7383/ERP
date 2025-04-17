import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/purchase/supplier.dart';
import 'package:erp/features/auth/logic/purchase/supplier_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart'; // Import Gap

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  @override
  void initState() {
    context.read<SupplierCubit>().fetchSuppliers();
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
          'Suppliers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<SupplierCubit, SupplierState>(
        listener: (context, state) {
          if (state is SupplierListLoaded && state.selectedSupplier != null) {
            _showSupplierDetailsPopup(context, state.selectedSupplier!);
            context.read<SupplierCubit>().resetSelectedSupplier();
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SupplierState state) {
    if (state is SupplierLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    } else if (state is SupplierError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is SupplierLoadingById || state is SupplierListLoaded) {
      final suppliers = (state is SupplierListLoaded)
          ? state.filteredSuppliers
          : (state as SupplierLoadingById).previousState is SupplierListLoaded
              ? (state.previousState as SupplierListLoaded).filteredSuppliers
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
                    hintText: 'Search by name, email, or phone',
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
                    context.read<SupplierCubit>().searchSuppliers(query);
                  },
                ),
              ),
              Expanded(
                child: suppliers.isEmpty
                    ? Center(
                        child: Text(
                          'No suppliers found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<SupplierCubit>().fetchSuppliers();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: suppliers.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final supplier = suppliers[index];
                            return _SupplierCard(supplier: supplier);
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is SupplierLoadingById) const ModernLoadingOverlay(),
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

  // --- Modern Supplier Details Popup ---
  void _showSupplierDetailsPopup(
    BuildContext context,
    SupplierData supplier,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return DefaultTabController(
          // Keep TabController
          length: 3, // Number of tabs
          child: Dialog(
            // Use Dialog instead of AlertDialog
            backgroundColor: Colors.grey[900], // Dark background for dialog
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16), // Rounded corners for dialog
            ),
            insetPadding: const EdgeInsets.symmetric(
                // Padding around dialog
                horizontal: 16,
                vertical: 24),
            child: SizedBox(
              // Constrain width
              width: screenWidth < 600
                  ? screenWidth * 0.9
                  : 600, // Responsive width
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content vertically
                children: [
                  // --- Styled Header ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[850], // Slightly different header background
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16), // Match dialog radius
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          // Keep avatar, style if needed
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          child: Text(supplier.supplierName.isNotEmpty
                              ? supplier.supplierName[0].toUpperCase()
                              : '?'),
                        ),
                        const Gap(16), // Consistent spacing
                        Expanded(
                          // Allow text to wrap if needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplier.supplierName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'Supplier ID: ${supplier.supplierId}',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // Close button added to header for better UX
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
                    color:
                        Colors.grey[850], // Match header or slightly different
                    child: TabBar(
                      labelColor: Colors.white, // Active tab text color
                      unselectedLabelColor:
                          Colors.grey[400], // Inactive tab text color
                      indicatorColor: Colors
                          .blueAccent, // Highlight color for active tab indicator
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Details'),
                        Tab(text: 'Transactions'),
                        Tab(text: 'Payments'),
                      ],
                    ),
                  ),

                  // --- Tab Content ---
                  // Use Flexible + Expanded or a fixed height Container
                  Flexible(
                    // Allows the TabBarView to take remaining space
                    child: Container(
                      // Optional: set a max height if Flexible causes issues
                      // height: 400, // Or MediaQuery.of(context).size.height * 0.5,
                      child: TabBarView(
                        children: [
                          // Details Tab - Pass the modern _DetailRow widget
                          _buildDetailsTab(supplier),
                          // Transactions Tab - Use styled list items
                          _buildTransactionsTab(supplier.transactionDtos),
                          // Payments Tab - Use styled list items
                          _buildPaymentsTab(supplier.supplierPayments),
                        ],
                      ),
                    ),
                  ),
                  // Removed actions block as close button is now in header
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Tab Builders using modern widgets ---

  Widget _buildDetailsTab(SupplierData supplier) {
    // Use SingleChildScrollView for potentially long details
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // Padding inside the tab content area
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use the modern _DetailRow widget
          _DetailRow(label: 'Account ID', value: supplier.accountId.toString()),
          _DetailRow(
              label: 'Total', value: '\$${supplier.total.toStringAsFixed(2)}'),
          _DetailRow(
              label: 'Paid to Date',
              value: '\$${supplier.paidToDate.toStringAsFixed(2)}'),
          _DetailRow(
              label: 'Balance Due',
              value: '\$${supplier.balanceDue.toStringAsFixed(2)}'),
          const Gap(20), // Spacing before next section
          Text(
            'Contact Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Slightly less bold than title
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const Gap(10),
          _DetailRow(label: 'Address', value: supplier.address ?? 'N/A'),
          _DetailRow(label: 'Phone', value: supplier.contactInfo ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(List<TransactionDto> transactions) {
    if (transactions.isEmpty) {
      return Center(
          child: Text('No transactions found.',
              style: TextStyle(color: Colors.grey[400])));
    }
    // Use ListView.separated for consistent spacing
    return ListView.separated(
      padding: const EdgeInsets.all(16), // Padding around the list
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Gap(8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        // Use a styled Container instead of Card+ListTile
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[800], // Background for list item
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.transaction,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis, // Prevent overflow
                    ),
                    const Gap(4),
                    Text(
                      transaction.dateTime
                          .toString()
                          .split(' ')[0], // Date only
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Gap(12), // Spacing between sections
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.amount < 0
                          ? Colors.red[300]
                          : Colors.green[300],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    // Balance Due
                    'Bal: \$${transaction.balanceDue.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(List<SupplierPayment> payments) {
    if (payments.isEmpty) {
      return Center(
          child: Text('No payments found.',
              style: TextStyle(color: Colors.grey[400])));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      separatorBuilder: (context, index) => const Gap(8),
      itemBuilder: (context, index) {
        final payment = payments[index];
        // Use a styled Container
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment #${payment.id}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    const Gap(4),
                    Text(
                      '${payment.paymentMethod} - ${payment.createdDate.toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Text(
                '\$${payment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: payment.amount < 0
                      ? Colors.red[300]
                      : Colors
                          .green[300], // Unlikely negative for payment but safe
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Custom Card Widget for Supplier List ---
class _SupplierCard extends StatelessWidget {
  final Supplier supplier; // Use the base Supplier object for the list

  const _SupplierCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    final BorderRadius cardBorderRadius = BorderRadius.circular(12);
    final Color hoverColor = Colors.white.withOpacity(0.05);
    final Color highlightColor = Colors.white.withOpacity(0.08);
    final Color splashColor = Colors.white.withOpacity(0.04);

    return InkWell(
      // InkWell for interaction feedback
      onTap: () {
        // Fetch full details when card is tapped
        context.read<SupplierCubit>().fetchSupplierById(supplier.supplierId);
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
        child: Row(
          // Use Row for Icon + Text layout
          children: [
            // Icon for visual cue
            Icon(
              Icons.business_center_outlined,
              color: Colors.grey[400],
              size: 28,
            ),
            const Gap(12),
            Expanded(
              // Allow text column to take remaining space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.supplierName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600, // Bold name
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6), // Spacing between lines
                  Text(
                    'ID: ${supplier.supplierId} • Acc: ${supplier.accountId}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Optional: Add an arrow or chevron icon if desired
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widget for Detail Rows in Popup (Modern Style) ---
// (Copied from previous examples)
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Adjusted padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Adjust width as needed for labels
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500, // Slightly bolder label
              ),
            ),
          ),
          const Gap(12), // Increased gap
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
