import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp/features/auth/data/entities/stock/prdouct.dart';
import 'package:erp/features/auth/logic/stock/product_bloc.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text("Product Inventory",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        backgroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            // Modern search bar
            _buildSearchBar(context),
            const SizedBox(height: 12),
            // Product list with improved spacing
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.8),
                        strokeWidth: 2.5,
                      ),
                    );
                  } else if (state is ProductError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.red[400], fontSize: 14),
                      ),
                    );
                  } else if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return Center(
                        child: Text(
                          "No products found",
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      );
                    }
                    return _buildProductList(context, state);
                  }
                  return Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      /* bottomNavigationBar: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoaded) {
            return _buildPaginationControls(context, state);
          }
          return const SizedBox.shrink();
        },
      ),*/
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon:
            Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[400]!, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
      onChanged: (query) => context.read<ProductCubit>().searchProducts(query),
    );
  }

  Widget _buildProductList(BuildContext context, ProductLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProductCubit>().fetchProducts();
      },
      color: Colors.white, // Explicitly set the color to make it visible
      backgroundColor: Colors.grey[800], // Optional: set background color
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0 && state.hasNextPage) {
            context.read<ProductCubit>().loadNextPage();
          } else if (details.primaryVelocity! > 0 && state.hasPreviousPage) {
            context.read<ProductCubit>().loadPreviousPage();
          }
        },
        child: ListView.separated(
          physics:
              const AlwaysScrollableScrollPhysics(), // Changed from BouncingScrollPhysics
          padding: const EdgeInsets.symmetric(
              vertical: 8), // Add padding here instead
          itemCount: state.products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _buildProductTile(context, state.products[index]),
        ),
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showProductDetails(context, product),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product icon with type indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: product.productOrService == 1
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  product.productOrService == 1
                      ? Icons.construction
                      : Icons.inventory_2,
                  color: product.productOrService == 1
                      ? Colors.blue[400]
                      : Colors.green[400],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'No description',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${product.sellPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.purchasePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status/Stock indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: product.productOrService == 1
                      ? (product.status == 1
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2))
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.productOrService == 1
                      ? (product.status == 1 ? 'Active' : 'Inactive')
                      : '${product.stockQuantity} in stock',
                  style: TextStyle(
                    color: product.productOrService == 1
                        ? (product.status == 1
                            ? Colors.green[400]
                            : Colors.red[400])
                        : Colors.blue[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget _buildPaginationControls(BuildContext context, ProductLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.grey[400]),
            onPressed: state.hasPreviousPage
                ? () => context.read<ProductCubit>().loadPreviousPage()
                : null,
          ),
          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onPressed: state.hasNextPage
                ? () => context.read<ProductCubit>().loadNextPage()
                : null,
          ),
        ],
      ),
    );
  }*/

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          product.productOrService == 1
                              ? Icons.construction
                              : Icons.inventory_2,
                          color: product.productOrService == 1
                              ? Colors.blue[400]
                              : Colors.green[400],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 24, color: Colors.grey[850]),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Type',
                            product.productOrService == 1
                                ? 'Service'
                                : 'Product'),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                            'Description',
                            product.description.isNotEmpty
                                ? product.description
                                : 'None'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Purchase Price',
                            '\$${product.purchasePrice.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Sell Price',
                            '\$${product.sellPrice.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        if (product.productOrService == 0)
                          _buildDetailRow('Stock Quantity',
                              product.stockQuantity.toString()),
                        if (product.productOrService == 1)
                          _buildDetailRow('Status',
                              product.status == 1 ? 'Active' : 'Inactive'),
                      ],
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[870],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                          ),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
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
        const SizedBox(width: 12),
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
    );
  }
}
