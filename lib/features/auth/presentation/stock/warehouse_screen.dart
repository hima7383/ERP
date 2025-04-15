// Imports (adjust paths as needed)
import 'package:erp/Core/widgets/genricori_dialogbox.dart'; // Path to your dialog
import 'package:erp/features/auth/data/entities/stock/warehouse.dart';
import 'package:erp/features/auth/logic/stock/warehouse_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your repository if needed for providing the Cubit

// --- Main Screen Widget ---
class WarehouseScreenProvider extends StatelessWidget {
  const WarehouseScreenProvider({super.key});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  
}


class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match CustomerScreen theme
      appBar: AppBar(
        title: const Text('Warehouses', style: TextStyle(color: Colors.white)), // Match CustomerScreen theme
        backgroundColor: Colors.black, // Match CustomerScreen theme
        scrolledUnderElevation: 0.0, // Match CustomerScreen theme
        centerTitle: false, // Align title left like CustomerScreen
      ),
      body: BlocConsumer<WarehouseCubit, WarehouseState>(
        listener: (context, state) {
          // Listen for when details are loaded to show the popup
          if (state is WarehouseListLoaded && state.selectedWarehouse != null) {
            final warehouseToShow = state.selectedWarehouse!; // Store details temporarily
            // Reset selection in state *before* showing dialog to prevent re-triggering
            context.read<WarehouseCubit>().resetSelectedWarehouse();
            // Show the details popup
            _showWarehouseDetailsPopup(context, warehouseToShow);
          }
           // Optional: Show a snackbar on error
           else if (state is WarehouseError) {
             ScaffoldMessenger.of(context)
               ..hideCurrentSnackBar()
               ..showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red[700],
                  ),
               );
           }
        },
        builder: (context, state) {
          // --- Loading State ---
          if (state is WarehouseLoading || state is WarehouseInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white, // Match CustomerScreen theme
              ),
            );
          }
          // --- Error State ---
          // Note: Error message is primarily shown via SnackBar in the listener now,
          // but builder can show a persistent error/retry if needed.
          if (state is WarehouseError && state.isRecoverable && state is! WarehouseListLoaded) {
            // Only show retry in builder if we don't have a list loaded in background
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                   Padding(
                     padding: const EdgeInsets.only(top: 16.0),
                     child: ElevatedButton(
                       onPressed: () => context.read<WarehouseCubit>().fetchWarehouses(),
                       child: const Text('Retry'),
                     ),
                   ),
                ],
              ),
            );
          }
          // --- Loaded State (or error state *with* existing data) ---
           if (state is WarehouseListLoaded) {
             return Column(
               children: [
                 _buildSearchBar(context), // Use consistent search bar
                 Expanded(
                   // Show list, or empty message if filtered list is empty
                   child: state.filteredWarehouses.isEmpty
                       ? Center(
                           child: Text(
                             context.read<WarehouseCubit>().allWarehouses.isEmpty
                                ? 'No warehouses available.' // Message if truly no data
                                : 'No warehouses match your search.', // Message if search yields no results
                             style: TextStyle(color: Colors.grey[400], fontSize: 14),
                           ),
                         )
                       : _buildWarehouseList(context, state), // Use consistent list builder
                 ),
               ],
             );
           }
          // --- Fallback/Unknown State ---
          // Should ideally not be reached if states are handled properly
          return const Center(
            child: Text(
              'Loading Warehouses...', // More user-friendly initial text
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  // --- Search Bar Widget ---
  Widget _buildSearchBar(BuildContext context) {
    // Styled to match CustomerScreen's search bar
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by Name, Address, or ID',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20), // Match style
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Consistent radius
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5), // Consistent focus
          ),
          filled: true,
          fillColor: Colors.grey[900], // Consistent fill
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjust padding
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14), // Consistent text style
        onChanged: (query) {
          context.read<WarehouseCubit>().searchWarehouses(query);
        },
      ),
    );
  }

  // --- Warehouse List Widget ---
  Widget _buildWarehouseList(BuildContext context, WarehouseListLoaded state) {
    // Structure matches CustomerScreen list (RefreshIndicator > ListView > Card > ListTile)
    return RefreshIndicator(
      onRefresh: () async {
        // Use the refresh method from Cubit
        await context.read<WarehouseCubit>().refreshWarehouses();
      },
      color: Colors.white,
      backgroundColor: Colors.grey[800],
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure refresh works even if list fits screen
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Padding for list items
        itemCount: state.filteredWarehouses.length,
        itemBuilder: (context, index) {
          final warehouse = state.filteredWarehouses[index];
          return Card(
            color: Colors.grey[900], // Match CustomerScreen card color
            margin: const EdgeInsets.symmetric(vertical: 5.0), // Consistent spacing
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Consistent shape
            elevation: 1, // Subtle elevation
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(
                warehouse.warehouseName, // Direct access from simplified Cubit
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  warehouse.address ?? 'No address provided',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
              onTap: () {
                // Fetch full details when tapped - Match CustomerScreen pattern
                context.read<WarehouseCubit>().fetchWarehouseById(warehouse.warehouseId);
              },
            ),
          );
        },
      ),
    );
  }

  // --- Details Popup ---
  void _showWarehouseDetailsPopup(BuildContext context, Warehouse warehouse) {
    // Using the assumed OrientationAwareDialog structure
    OrientationAwareDialog.show(
      context: context,
      title: warehouse.warehouseName,
      subtitle: warehouse.address ?? 'No address',
      statusWidget: _buildStatusWidget(warehouse), // Use helper for status display
      tabCount: 3,
      tabLabels: const ['Details', 'Receiving', 'Delivery'], // Shortened labels
      tabViews: [
        _buildDetailsTab(warehouse),
        _buildReceivingVouchersTab(warehouse),
        _buildDeliveryVouchersTab(warehouse),
      ],
    );
  }

  // Helper to build the status widget (customize as needed)
  Widget _buildStatusWidget(Warehouse warehouse) {
    // Example: Simple status based on if any vouchers exist
    bool hasActivity = warehouse.receivingVouchers.isNotEmpty || warehouse.deliveryVouchers.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hasActivity
            ? Colors.green.withOpacity(0.15)
            : Colors.blueGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasActivity ? Colors.green.withOpacity(0.3) : Colors.blueGrey.withOpacity(0.3),
          width: 0.5
        )
      ),
      child: Text(
        hasActivity ? 'Active' : 'Idle',
        style: TextStyle(
          color: hasActivity ? Colors.green[300] : Colors.blueGrey[300],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  // --- Tab Builder: Details ---
  Widget _buildDetailsTab(Warehouse warehouse) {
    // Cleaned up display
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Warehouse ID', warehouse.warehouseId.toString()),
          _buildDetailRow('Address', warehouse.address ?? 'N/A'), // Use N/A for clarity
           const SizedBox(height: 16),
           const Text("Summary:", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
           const Divider(color: Colors.white24),
           _buildDetailRow('Stock Transactions', warehouse.stockTransactions.length.toString()),
          _buildDetailRow('Receiving Vouchers', warehouse.receivingVouchers.length.toString()),
          _buildDetailRow('Delivery Vouchers', warehouse.deliveryVouchers.length.toString()),
        ],
      ),
    );
  }

  // --- Tab Builder: Receiving Vouchers ---
  Widget _buildReceivingVouchersTab(Warehouse warehouse) {
    if (warehouse.receivingVouchers.isEmpty) {
      return Center(child: Text("No receiving vouchers found.", style: TextStyle(color: Colors.grey[400])));
    }
    // Use consistent Card/ListTile styling
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: warehouse.receivingVouchers.length,
      itemBuilder: (context, index) {
        final voucher = warehouse.receivingVouchers[index];
        return Card(
          color: Colors.grey[850], // Slightly lighter card for tabs
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: ListTile(
             contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              'Voucher #${voucher.receivingVoucherId}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const SizedBox(height: 4),
                Text(
                  'Date: ${voucher.receivingDate.year}-${voucher.receivingDate.month.toString().padLeft(2, '0')}-${voucher.receivingDate.day.toString().padLeft(2, '0')}', // Formatted Date
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                if (voucher.notes != null && voucher.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Notes: ${voucher.notes}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                    ),
                  ),
                 // TODO: Add more relevant details like Supplier ID, Status ID if needed
              ],
            ),
             trailing: Icon(Icons.receipt_long, color: Colors.blue[300], size: 20),
          ),
        );
      },
    );
  }

  // --- Tab Builder: Delivery Vouchers ---
  Widget _buildDeliveryVouchersTab(Warehouse warehouse) {
     if (warehouse.deliveryVouchers.isEmpty) {
      return Center(child: Text("No delivery vouchers found.", style: TextStyle(color: Colors.grey[400])));
    }
    // Ensure DeliveryVoucher entity has necessary fields (e.g., deliveryVoucherId, deliveryDate)
    return ListView.builder(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: warehouse.deliveryVouchers.length,
      itemBuilder: (context, index) {
        final voucher = warehouse.deliveryVouchers[index];
        return Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: ListTile(
             contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              'Voucher #${voucher.deliveryVoucherId}', // Use actual ID
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                // Use actual date field
                 'Date: ${voucher.deliveryDate.year}-${voucher.deliveryDate.month.toString().padLeft(2, '0')}-${voucher.deliveryDate.day.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
            trailing: Icon(Icons.local_shipping, color: Colors.green[300], size: 20),
          ),
        );
      },
    );
  }

  // --- Helper: Detail Row ---
  Widget _buildDetailRow(String label, String value) {
    // Consistent helper
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0), // Adjusted padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Slightly adjusted width
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[300], // Slightly lighter label
                fontWeight: FontWeight.w500, // Medium weight
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A', // Use N/A for empty values
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}