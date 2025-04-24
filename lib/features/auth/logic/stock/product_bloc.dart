import 'package:erp/features/auth/data/entities/stock/prdouct.dart';
import 'package:erp/features/auth/data/repos/stock/product_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import the ProductRepository

abstract class ProductState {}

class ProductLoading extends ProductState {}
class ProductOffline extends ProductState {
  ProductOffline();
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
class ProductLoadingById extends ProductState {
  final ProductLoaded? previousState;
  ProductLoadingById([this.previousState]);
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  ProductLoaded({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;
  List<Product> _allProducts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  ProductCubit(this._repository) : super(ProductLoading());

  Future<void> fetchProducts({int page = 1}) async {
    emit(ProductLoading());
    try {
      final response = await _repository.fetchProducts(page: page);
      _allProducts = response.products;
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _hasNextPage = response.hasNextPage;
      _hasPreviousPage = response.hasPreviousPage;

      emit(ProductLoaded(
        products: _allProducts,
        currentPage: _currentPage,
        totalPages: _totalPages,
        hasNextPage: _hasNextPage,
        hasPreviousPage: _hasPreviousPage,
      ));
    }
    on Exception catch (e) {
    if (e.toString().contains("No internet connection")) {
      emit(ProductOffline()); // New state for offline mode
    }
     else {
      emit(ProductError('Failed to load products: $e'));
    }
  }
  }

  void loadNextPage() {
    if (_currentPage < _totalPages) {
      fetchProducts(page: _currentPage + 1);
    }
  }

  void loadPreviousPage() {
    if (_currentPage > 1) {
      fetchProducts(page: _currentPage - 1);
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(ProductLoaded(
        products: _allProducts,
        currentPage: _currentPage,
        totalPages: _totalPages,
        hasNextPage: _hasNextPage,
        hasPreviousPage: _hasPreviousPage,
      ));
    } else {
      final filteredProducts = _allProducts.where((product) {
        // Convert query to lowercase for case-insensitive search
        final lowerCaseQuery = query.toLowerCase();

        // Check if the query matches any of the specified fields
        return product.name.toLowerCase().contains(lowerCaseQuery) ||
            product.description.toLowerCase().contains(lowerCaseQuery) ||
            product.id.toString().contains(lowerCaseQuery) ||
            product.status.toString().contains(lowerCaseQuery) ||
            (product.supplierId != null &&
                product.supplierId.toString().contains(lowerCaseQuery)) ||
            product.purchasePrice.toString().contains(lowerCaseQuery) ||
            product.sellPrice.toString().contains(lowerCaseQuery);
      }).toList();

      emit(ProductLoaded(
        products: filteredProducts,
        currentPage: _currentPage,
        totalPages: _totalPages,
        hasNextPage: _hasNextPage,
        hasPreviousPage: _hasPreviousPage,
      ));
    }
  }

  /*void filterProducts({String? category, String? status}) {
    List<Product> filteredProducts = _allProducts;

    // Filter by category (if implemented)
    if (category != null && category != 'All') {
      filteredProducts = filteredProducts
          .where((product) => product.categoriesIds.contains(int.tryParse(category)))
          .toList();
    }

    // Filter by status
    if (status != null && status != 'All') {
      final isActive = status == 'Active';
      filteredProducts = filteredProducts
          .where((product) => product.status == (isActive ? 1 : 0))
          .toList();
    }

    emit(ProductLoaded(
      products: filteredProducts,
      currentPage: _currentPage,
      totalPages: _totalPages,
      hasNextPage: _hasNextPage,
      hasPreviousPage: _hasPreviousPage,
    ));
  }*/
}
