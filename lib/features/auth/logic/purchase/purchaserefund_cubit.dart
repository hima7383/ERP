import 'package:erp/features/auth/data/entities/purchase/purchasereturn.dart';
import 'package:erp/features/auth/data/repos/purchase/purchaserefund_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';
import 'package:erp/features/auth/data/repos/stock/product_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PurchaseInvoicerefundState {}

class PurchaseInvoicerefundLoading extends PurchaseInvoicerefundState {}

class PurchaseInvoicerefundLoadingById extends PurchaseInvoicerefundState {
  final PurchaseInvoicerefundLoaded? previousState;

  PurchaseInvoicerefundLoadingById([this.previousState]);
} // New loading state for fetching by ID

class PurchaseInvoicerefundError extends PurchaseInvoicerefundState {
  final String message;
  PurchaseInvoicerefundError(this.message);
}

class PurchaseInvoicerefundLoaded extends PurchaseInvoicerefundState {
  final List<PurchaseInvoiceRefund> invoices;
  final List<PurchaseInvoiceRefund> filteredInvoices;
  final PurchaseInvoiceRefund? selectedInvoice;
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
      emit(PurchaseInvoicerefundLoaded(
        _allInvoices,
        productNames: {},
        supplierNames: {},
      ));
      return;
    }

    emit(PurchaseInvoicerefundLoading());

    try {
      _allInvoices = await _repository.fetchPurchaseInvoicesrefund();
      emit(PurchaseInvoicerefundLoaded(
        _allInvoices,
        productNames: {},
        supplierNames: {},
      ));
    } catch (e) {
      emit(PurchaseInvoicerefundError('Failed to load purchase invoices: $e'));
    }
  }

  void resetSelectedInvoice() {
    if (state is PurchaseInvoicerefundLoaded) {
      final currentState = state as PurchaseInvoicerefundLoaded;
      emit(PurchaseInvoicerefundLoaded(
        currentState.invoices,
        filteredInvoices: currentState.filteredInvoices,
        selectedInvoice: null,
        productNames: {},
        supplierNames: {},
      ));
    }
  }

  Future<Map<int, String>> fetchProductNamesForInvoice(
      PurchaseInvoiceRefund invoice) async {
    final productNames = <int, String>{};
    final productRepo = ProductRepository();

    for (var item in invoice.purchaseReturnItemsDto) {
      try {
        final product = await productRepo.fetchProductById(item.productId);
        productNames[item.productId] = product.productName;
      } catch (e) {
        productNames[item.productId] = 'Product #${item.productId}';
      }
    }

    return productNames;
  }

  Future<Map<int, String>> fetchsupplierNamesForInvoice(
      PurchaseInvoiceRefund invoice) async {
    final supplierNames = <int, String>{};
    final supplierRepo = SupplierRepository();

    try {
      final supplier = await supplierRepo.fetchSuppliers();
      for (var supp in supplier) {
        if (supp.supplierId == invoice.supplierId) {
          supplierNames[invoice.supplierId] = supp.supplierName;
          break; // No need to continue once found
        }
      }
    } catch (e) {
      supplierNames[invoice.supplierId] = 'Supplier #${invoice.supplierId}';
    }

    return supplierNames;
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
        currentState.invoices,
        filteredInvoices: filteredInvoices,
        selectedInvoice: currentState.selectedInvoice,
        productNames: currentState.productNames,
        supplierNames: currentState.supplierNames,
      ));
    }
  }

  Future<void> fetchPurchaseInvoicerefundById(int id) async {
    if (state is! PurchaseInvoicerefundLoaded) return;

    final currentState = state as PurchaseInvoicerefundLoaded;
    emit(PurchaseInvoicerefundLoadingById(currentState));

    try {
      final fetchedInvoice = await _repository.fetchPurchaseInvoicerefundById(id);
      final productNames = await fetchProductNamesForInvoice(fetchedInvoice);
      final supplierNames = await fetchsupplierNamesForInvoice(fetchedInvoice);

      emit(PurchaseInvoicerefundLoaded(
        currentState.invoices,
        filteredInvoices: currentState.filteredInvoices,
        selectedInvoice: fetchedInvoice,
        productNames: productNames,
        supplierNames: supplierNames,
      ));
    } catch (e) {
      emit(PurchaseInvoicerefundError('Failed to load invoice: $e'));
      emit(currentState); // Revert to previous state
    }
  }
}