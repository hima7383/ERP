// Imports (adjust paths as needed)
import 'package:erp/Core/widgets/genricori_dialogbox.dart'; // Path to your dialog
import 'package:erp/features/auth/data/entities/stock/warehouse_permesion.dart';
import 'package:erp/features/auth/logic/stock/warehosue_permesion_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      backgroundColor: Colors.black, // Match theme
      appBar: AppBar(
        title: const Text('Price Lists', style: TextStyle(color: Colors.white)), // Match theme
        backgroundColor: Colors.black, // Match theme
        scrolledUnderElevation: 0.0, // Match theme
        centerTitle: false,
      ),
      body: BlocConsumer<PriceListCubit, PriceListState>(
        listener: (context, state) {
          if (state is PriceListLoaded && state.selectedPriceListDetails != null) {
            final detailsToShow = state.selectedPriceListDetails!;
            context.read<PriceListCubit>().resetSelectedPriceList(); // Reset before showing
            _showPriceListDetailsPopup(context, detailsToShow);
          } else if (state is PriceListError) {
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
          if (state is PriceListLoading || state is PriceListInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          // --- Error State (Persistent) ---
          if (state is PriceListError && state is! PriceListLoaded) {
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
                  if (state.isRecoverable)
                   Padding(
                     padding: const EdgeInsets.only(top: 16.0),
                     child: ElevatedButton(
                       onPressed: () => context.read<PriceListCubit>().fetchPriceLists(),
                       child: const Text('Retry'),
                     ),
                   ),
                ],
              ),
            );
          }
          // --- Loaded State ---
           if (state is PriceListLoaded) {
            return Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: state.filteredPriceLists.isEmpty
                      ? Center(
                          child: Text(
                             context.read<PriceListCubit>().allPriceLists.isEmpty
                                ? 'No price lists available.'
                                : 'No price lists match your search.',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        )
                      : _buildPriceListList(context, state), // Use updated list builder
                ),
              ],
            );
          }
          // --- Fallback State ---
          return const Center(
            child: Text('Loading Price Lists...', style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }

  // --- Search Bar Widget ---
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by Name or ID',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (query) {
          context.read<PriceListCubit>().searchPriceLists(query);
        },
      ),
    );
  }

  // --- Price List Summary List Widget ---
  Widget _buildPriceListList(BuildContext context, PriceListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PriceListCubit>().refreshPriceLists();
      },
      color: Colors.white,
      backgroundColor: Colors.grey[800],
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        itemCount: state.filteredPriceLists.length,
        itemBuilder: (context, index) {
          final priceList = state.filteredPriceLists[index]; // This is PriceListSummary
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(
                priceList.priceListName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "${priceList.numberOfProducts} Product(s)", // Show product count
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Icon(
                priceList.isActive ? Icons.check_circle : Icons.cancel,
                color: priceList.isActive ? Colors.green[400] : Colors.red[400],
                size: 20,
              ),
              onTap: () {
                // Fetch full details when tapped
                context.read<PriceListCubit>().fetchPriceListById(priceList.priceListId);
              },
            ),
          );
        },
      ),
    );
  }

  // --- Details Popup ---
  void _showPriceListDetailsPopup(BuildContext context, PriceListDetails details) {
    OrientationAwareDialog.show(
      context: context,
      title: details.priceListName,
      subtitle: details.isActive ? 'Status: Active' : 'Status: Inactive', // Subtitle indicating status
      statusWidget: _buildStatusWidget(details.isActive), // Reusable status widget
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
        color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
         border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 0.5
        )
      ),
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
          _buildDetailRow('Total Items', details.priceListItems.length.toString()),
        ],
      ),
    );
  }

  // --- Tab Builder: Products/Items ---
  Widget _buildProductsTab(PriceListDetails details) {
    if (details.priceListItems.isEmpty) {
      return Center(child: Text("No products found in this price list.", style: TextStyle(color: Colors.grey[400])));
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
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              item.productName ?? 'Product ID: ${item.productId}', // Show name or ID
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              '\$${item.price.toStringAsFixed(2)}', // Format price
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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