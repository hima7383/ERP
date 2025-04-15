import 'package:erp/features/auth/data/entities/purchase/purchasereturn.dart';
import 'package:erp/features/auth/data/repos/purchase/purchaserefund_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';
import 'package:erp/features/auth/data/repos/stock/product_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PurchaseInvoicerefundState {}

class PurchaseInvoicerefundLoading extends PurchaseInvoicerefundState {}

class PurchaseInvoicerefundError extends PurchaseInvoicerefundState {
  final String message;
  PurchaseInvoicerefundError(this.message);
}

class PurchaseInvoicerefundLoaded extends PurchaseInvoicerefundState {
  final List<PurchaseInvoiceRefund> invoices;
  final List<PurchaseInvoiceRefund> filteredInvoices;
  final PurchaseInvoiceRefund?
      selectedInvoice; // Store selected invoice separately
  final Map<int, String> productNames;
  final Map<int, String> supplierNames;

  PurchaseInvoicerefundLoaded(
    this.invoices, {
    List<PurchaseInvoiceRefund>? filteredInvoices,
    this.selectedInvoice,
    required this.productNames,
    required this.supplierNames,
  }) : filteredInvoices = filteredInvoices ?? invoices;
}

class PurchaseInvoicerefundCubit extends Cubit<PurchaseInvoicerefundState> {
  final PurchaseInvoicerefundRepository _repository;
  List<PurchaseInvoiceRefund> _allInvoices = [];

  PurchaseInvoicerefundCubit(this._repository)
      : super(PurchaseInvoicerefundLoading());

  Future<void> fetchPurchaseInvoices() async {
    if (_allInvoices.isNotEmpty) {
      emit(PurchaseInvoicerefundLoaded(_allInvoices,
          productNames: {}, supplierNames: {}));
      return;
    }
    emit(PurchaseInvoicerefundLoading());
    try {
      _allInvoices = await _repository.fetchPurchaseInvoicesrefund();
      emit(PurchaseInvoicerefundLoaded(_allInvoices,
          productNames: {}, supplierNames: {}));
    } catch (e) {
      emit(PurchaseInvoicerefundError('Failed to load purchase invoices: $e'));
    }
  }

  void resetSelectedInvoice() {
    if (state is PurchaseInvoicerefundLoaded) {
      final currentState = state as PurchaseInvoicerefundLoaded;
      emit(PurchaseInvoicerefundLoaded(
        supplierNames: {},
        productNames: {},
        currentState.invoices,
        filteredInvoices: currentState.filteredInvoices,
        selectedInvoice: null, // Reset selected invoice
      ));
    }
  }

  void searchPurchaseInvoices(String query) {
    resetSelectedInvoice();
    if (state is PurchaseInvoicerefundLoaded) {
      final currentState = state as PurchaseInvoicerefundLoaded;
      final filteredInvoices = query.isEmpty
          ? _allInvoices
          : _allInvoices
              .where((invoice) =>
                  invoice.purchaseInvoiceRefundId.toString().contains(query) ||
                  invoice.totalAmount.toString().contains(query) ||
                  invoice.paymentStatus
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
      emit(PurchaseInvoicerefundLoaded(
        supplierNames: {},
        productNames: {},
        _allInvoices,
        filteredInvoices: filteredInvoices,
        selectedInvoice: currentState.selectedInvoice, // Keep selected invoice
      ));
    }
  }

  Future<Map<int, String>> fetchProductNamesForInvoice(
      PurchaseInvoiceRefund invoice) async {
    final productNames = <int, String>{};
    final productRepo = ProductRepository();

    for (var item in invoice.purchaseReturnItemsDto) {
      print(item);
      try {
        final product = await productRepo.fetchProductById(item.productId);

        // Use ProductDetailEntity to get the product name
        productNames[item.productId] = product.productName;
      } catch (e) {
        print("Something went wrong: $e"); // Debug: Print the error
        productNames[item.productId] = 'Product #${item.productId}'; // Fallback
      }
    }

    return productNames;
  }

  Future<Map<int, String>> fetchsupplierNamesForInvoice(
      PurchaseInvoiceRefund invoice) async {
    final supplierNames = <int, String>{};
    final supplierRepo = SupplierRepository();

    for (var item in invoice.purchaseReturnItemsDto) {
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

  Future<void> fetchPurchaseInvoicerefundById(int id) async {
    print('Fetching invoice by ID: $id');

    try {
      final fetchedInvoice =
          await _repository.fetchPurchaseInvoicerefundById(id);
      final productNames = await fetchProductNamesForInvoice(fetchedInvoice);
      final supplierNames = await fetchsupplierNamesForInvoice(fetchedInvoice);

      if (state is PurchaseInvoicerefundLoaded) {
        final currentState = state as PurchaseInvoicerefundLoaded;

        // ✅ Keep the original list and update only the selected invoice
        emit(PurchaseInvoicerefundLoaded(
          supplierNames: supplierNames,
          productNames: productNames,
          currentState.invoices,
          filteredInvoices: currentState.filteredInvoices,
          selectedInvoice:
              fetchedInvoice, // Store the fetched invoice separately
        ));
      }
    } catch (e) {
      emit(PurchaseInvoicerefundError('Failed to load purchase invoice: $e'));
    }
  }
}
