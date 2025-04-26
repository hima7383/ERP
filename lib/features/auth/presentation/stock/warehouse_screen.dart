// Imports (adjust paths as needed)
import 'package:erp/Core/widgets/genricori_dialogbox.dart'; // Path to your dialog
import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/stock/warehouse.dart';
import 'package:erp/features/auth/logic/stock/warehouse_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
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
    return BlocConsumer<WarehouseCubit, WarehouseState>(
      listener: (context, state) {
        if (state is WarehouseError) {
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
                  onPressed: () =>
                      context.read<WarehouseCubit>().fetchWarehouses(),
                  child: const Text("Retry",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }
        if (state is WarehouseListLoaded && state.selectedWarehouse != null) {
          _showWarehouseDetailsPopup(context, state.selectedWarehouse!);
          context.read<WarehouseCubit>().resetSelectedWarehouse();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            title: const Text(
              'Warehouses',
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

  Widget _buildBody(BuildContext context, WarehouseState state) {
    if (state is WarehouseLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (state is WarehouseError) {
      return Center(
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
              onPressed: () => context.read<WarehouseCubit>().fetchWarehouses(),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    } else if (state is WarehouseLoadingById || state is WarehouseListLoaded) {
      final warehouses = (state is WarehouseListLoaded)
          ? state.filteredWarehouses
          : (state as WarehouseLoadingById).previousState is WarehouseListLoaded
              ? (state.previousState as WarehouseListLoaded).filteredWarehouses
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
                    hintText: 'Search by Name, Address, or ID',
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
                    context.read<WarehouseCubit>().searchWarehouses(query);
                  },
                ),
              ),
              Expanded(
                child: warehouses.isEmpty
                    ? Center(
                        child: Text(
                          context.read<WarehouseCubit>().allWarehouses.isEmpty
                              ? 'No warehouses available'
                              : 'No warehouses match your search',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<WarehouseCubit>()
                              .fetchWarehouses();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: warehouses.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final warehouse = warehouses[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  warehouse.warehouseName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      warehouse.address ??
                                          'No address provided',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                trailing: const Icon(Icons.info_outline,
                                    color: Colors.blue),
                                onTap: () {
                                  context
                                      .read<WarehouseCubit>()
                                      .fetchWarehouseById(
                                          warehouse.warehouseId);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is WarehouseLoadingById)
            const ModernLoadingOverlay(msg: "Warehouse"),
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

  // --- Details Popup ---
  void _showWarehouseDetailsPopup(BuildContext context, Warehouse warehouse) {
    // Using the assumed OrientationAwareDialog structure
    OrientationAwareDialog.show(
      context: context,
      title: warehouse.warehouseName,
      subtitle: warehouse.address ?? 'No address',
      statusWidget:
          _buildStatusWidget(warehouse), // Use helper for status display
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
    bool hasActivity = warehouse.receivingVouchers.isNotEmpty ||
        warehouse.deliveryVouchers.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: hasActivity
              ? Colors.green.withOpacity(0.15)
              : Colors.blueGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasActivity
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blueGrey.withOpacity(0.3),
              width: 0.5)),
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
          _buildDetailRow(
              'Address', warehouse.address ?? 'N/A'), // Use N/A for clarity
          const SizedBox(height: 16),
          const Text("Summary:",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
          _buildDetailRow('Stock Transactions',
              warehouse.stockTransactions.length.toString()),
          _buildDetailRow('Receiving Vouchers',
              warehouse.receivingVouchers.length.toString()),
          _buildDetailRow('Delivery Vouchers',
              warehouse.deliveryVouchers.length.toString()),
        ],
      ),
    );
  }

  // --- Tab Builder: Receiving Vouchers ---
  Widget _buildReceivingVouchersTab(Warehouse warehouse) {
    if (warehouse.receivingVouchers.isEmpty) {
      return Center(
          child: Text("No receiving vouchers found.",
              style: TextStyle(color: Colors.grey[400])));
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
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              'Voucher #${voucher.receivingVoucherId}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
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
            trailing:
                Icon(Icons.receipt_long, color: Colors.blue[300], size: 20),
          ),
        );
      },
    );
  }

  // --- Tab Builder: Delivery Vouchers ---
  Widget _buildDeliveryVouchersTab(Warehouse warehouse) {
    if (warehouse.deliveryVouchers.isEmpty) {
      return Center(
          child: Text("No delivery vouchers found.",
              style: TextStyle(color: Colors.grey[400])));
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
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              'Voucher #${voucher.deliveryVoucherId}', // Use actual ID
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                // Use actual date field
                'Date: ${voucher.deliveryDate.year}-${voucher.deliveryDate.month.toString().padLeft(2, '0')}-${voucher.deliveryDate.day.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
            trailing:
                Icon(Icons.local_shipping, color: Colors.green[300], size: 20),
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
