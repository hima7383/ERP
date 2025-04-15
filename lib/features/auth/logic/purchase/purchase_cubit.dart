import 'package:erp/features/auth/data/entities/purchase/purchase_invoices.dart';

import 'package:erp/features/auth/data/repos/purchase/purchase_repo.dart';

import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';

import 'package:erp/features/auth/data/repos/stock/product_repo.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PurchaseInvoiceState {}

class PurchaseInvoiceLoading extends PurchaseInvoiceState {}

class PurchaseInvoiceError extends PurchaseInvoiceState {
  final String message;

  PurchaseInvoiceError(this.message);
}

class PurchaseInvoiceLoaded extends PurchaseInvoiceState {
  final List<PurchaseInvoice> invoices;

  final List<PurchaseInvoice> filteredInvoices;

  final PurchaseInvoice? selectedInvoice; // Store selected invoice separately

  final Map<int, String> productNames;

  final Map<int, String> supplierNames;

  PurchaseInvoiceLoaded(
    this.invoices, {
    List<PurchaseInvoice>? filteredInvoices,
    this.selectedInvoice,
    required this.productNames,
    required this.supplierNames,
  }) : filteredInvoices = filteredInvoices ?? invoices;
}

class PurchaseInvoiceCubit extends Cubit<PurchaseInvoiceState> {
  final PurchaseInvoiceRepository _repository;

  List<PurchaseInvoice> _allInvoices = [];

  PurchaseInvoiceCubit(this._repository) : super(PurchaseInvoiceLoading());

  Future<void> fetchPurchaseInvoices() async {
    if (_allInvoices.isNotEmpty) {
      emit(PurchaseInvoiceLoaded(
        supplierNames: {},
        _allInvoices,
        productNames: {},
      ));

      return;
    }

    emit(PurchaseInvoiceLoading());

    try {
      _allInvoices = await _repository.fetchPurchaseInvoices();

      emit(PurchaseInvoiceLoaded(
        supplierNames: {},
        _allInvoices,
        productNames: {},
      ));
    } catch (e) {
      emit(PurchaseInvoiceError('Failed to load purchase invoices: $e'));
    }
  }

  void resetSelectedInvoice() {
    if (state is PurchaseInvoiceLoaded) {
      final currentState = state as PurchaseInvoiceLoaded;

      emit(PurchaseInvoiceLoaded(
        supplierNames: {},

        currentState.invoices,

        filteredInvoices: currentState.filteredInvoices,

        selectedInvoice: null,

        productNames: {}, // Reset selected invoice
      ));
    }
  }

  Future<Map<int, String>> fetchProductNamesForInvoice(
      PurchaseInvoice invoice) async {
    final productNames = <int, String>{};

    final productRepo = ProductRepository();

    for (var item in invoice.items) {
      try {
        final product = await productRepo.fetchProductById(item.productId);

        // Use ProductDetailEntity to get the product name

        productNames[item.productId] = product.productName;
      } catch (e) {
        productNames[item.productId] = 'Product #${item.productId}'; // Fallback
      }
    }

    return productNames;
  }

  Future<Map<int, String>> fetchsupplierNamesForInvoice(
      PurchaseInvoice invoice) async {
    final supplierNames = <int, String>{};

    final supplierRepo = SupplierRepository();

    for (var item in invoice.items) {
      print(item);

      try {
        final supplier = await supplierRepo.fetchSuppliers();

        for (var supp in supplier) {
          if (supp.supplierId == invoice.supplierId) {
            supplierNames[invoice.supplierId] = supp.supplierName;
          }
        }
      } catch (e) {
        print("Something went wrong: $e"); // Debug: Print the error

        supplierNames[invoice.supplierId] =
            'Supplier #${invoice.supplierId}'; // Fallback
      }
    }

    return supplierNames;
  }

  void searchPurchaseInvoices(String query) {
    resetSelectedInvoice();

    if (state is PurchaseInvoiceLoaded) {
      final currentState = state as PurchaseInvoiceLoaded;

      final filteredInvoices = query.isEmpty
          ? _allInvoices
          : _allInvoices
              .where((invoice) =>
                  invoice.purchaseInvoiceId.toString().contains(query) ||
                  invoice.totalAmount.toString().contains(query) ||
                  invoice.paymentStatus
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();

      emit(PurchaseInvoiceLoaded(
        productNames: {},

        supplierNames: {},

        _allInvoices,

        filteredInvoices: filteredInvoices,

        selectedInvoice: currentState.selectedInvoice, // Keep selected invoice
      ));
    }
  }

  Future<void> fetchPurchaseInvoiceById(int id) async {
    try {
      final fetchedInvoice = await _repository.fetchPurchaseInvoiceById(id);

      final productNames = await fetchProductNamesForInvoice(fetchedInvoice);

      final supplierNames = await fetchsupplierNamesForInvoice(fetchedInvoice);

      //print('Product Names: $productNames');

      if (state is PurchaseInvoiceLoaded) {
        final currentState = state as PurchaseInvoiceLoaded;

        // ✅ Keep the original list and update only the selected invoice

        emit(PurchaseInvoiceLoaded(
          supplierNames: supplierNames,

          currentState.invoices,

          filteredInvoices: currentState.filteredInvoices,

          selectedInvoice: fetchedInvoice,

          productNames: productNames,

          // Store the fetched invoice separately
        ));
      }
    } catch (e) {
      emit(PurchaseInvoiceError('Failed to load purchase invoice: $e'));
    }
  }
}
