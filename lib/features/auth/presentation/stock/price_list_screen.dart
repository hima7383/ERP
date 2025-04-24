// Imports (adjust paths as needed)
import 'package:erp/Core/widgets/genricori_dialogbox.dart'; // Path to your dialog
import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/stock/warehouse_permesion.dart';
import 'package:erp/features/auth/logic/stock/price_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
// Import your repository if needed for providing the Cubit

// --- Main Screen Widget ---
class PriceListScreenProvider extends StatelessWidget {
  const PriceListScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit to the screen
    throw UnimplementedError('PriceListCubit should be provided here.');
  }
}

class PriceListScreen extends StatelessWidget {
  const PriceListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PriceListCubit, PriceListState>(
      listener: (context, state) {
        if (state is PriceListError) {
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
                            onPressed: () => context.read<PriceListCubit>().fetchPriceLists(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
        }
        if (state is PriceListLoaded &&
            state.selectedPriceListDetails != null) {
          _showPriceListDetailsPopup(context, state.selectedPriceListDetails!);
          context.read<PriceListCubit>().resetSelectedPriceList();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            title: const Text(
              'Price Lists',
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

  Widget _buildBody(BuildContext context, PriceListState state) {
    if (state is PriceListLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (state is PriceListError) {
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
                            onPressed: () => context.read<PriceListCubit>().fetchPriceLists(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
    } else if (state is PriceListLoadingById || state is PriceListLoaded) {
      final priceLists = (state is PriceListLoaded)
          ? state.filteredPriceLists
          : (state as PriceListLoadingById).previousState is PriceListLoaded
              ? (state.previousState as PriceListLoaded).filteredPriceLists
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
                    hintText: 'Search by Name or ID',
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
                    context.read<PriceListCubit>().searchPriceLists(query);
                  },
                ),
              ),
              Expanded(
                child: priceLists.isEmpty
                    ? Center(
                        child: Text(
                          context.read<PriceListCubit>().allPriceLists.isEmpty
                              ? 'No price lists available'
                              : 'No price lists match your search',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<PriceListCubit>()
                              .fetchPriceLists();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: priceLists.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final priceList = priceLists[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  priceList.priceListName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${priceList.numberOfProducts} Products',
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                trailing: Text(
                                  priceList.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: priceList.isActive
                                        ? Colors.green[400]
                                        : Colors.red[400],
                                  ),
                                ),
                                onTap: () {
                                  context
                                      .read<PriceListCubit>()
                                      .fetchPriceListById(
                                          priceList.priceListId);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is PriceListLoadingById)
            const ModernLoadingOverlay(msg: "Price List"),
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
  void _showPriceListDetailsPopup(
      BuildContext context, PriceListDetails details) {
    OrientationAwareDialog.show(
      context: context,
      title: details.priceListName,
      subtitle: details.isActive
          ? 'Status: Active'
          : 'Status: Inactive', // Subtitle indicating status
      statusWidget:
          _buildStatusWidget(details.isActive), // Reusable status widget
      tabCount: 2, // Details Tab and Products Tab
      tabLabels: const ['Details', 'Products'],
      tabViews: [
        _buildDetailsTab(details),
        _buildProductsTab(details), // Tab for price list items
      ],
    );
  }

  // Helper to build the status widget for active/inactive
  Widget _buildStatusWidget(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              width: 0.5)),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green[300] : Colors.red[300],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- Tab Builder: Details ---
  Widget _buildDetailsTab(PriceListDetails details) {
    // Simple tab showing basic info
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Price List ID', details.priceListId.toString()),
          _buildDetailRow('Name', details.priceListName),
          _buildDetailRow('Status', details.isActive ? 'Active' : 'Inactive'),
          _buildDetailRow(
              'Total Items', details.priceListItems.length.toString()),
        ],
      ),
    );
  }

  // --- Tab Builder: Products/Items ---
  Widget _buildProductsTab(PriceListDetails details) {
    if (details.priceListItems.isEmpty) {
      return Center(
          child: Text("No products found in this price list.",
              style: TextStyle(color: Colors.grey[400])));
    }
    // Display list of PriceListItem
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: details.priceListItems.length,
      itemBuilder: (context, index) {
        final item = details.priceListItems[index];
        return Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              item.productName ??
                  'Product ID: ${item.productId}', // Show name or ID
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              '\$${item.price.toStringAsFixed(2)}', // Format price
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            // Optionally add subtitle with more info if available (e.g., SKU)
          ),
        );
      },
    );
  }

  // --- Helper: Detail Row (Reused) ---
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
