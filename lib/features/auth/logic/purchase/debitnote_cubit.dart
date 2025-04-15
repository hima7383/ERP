import 'package:erp/features/auth/data/entities/purchase/debit_note.dart';
import 'package:erp/features/auth/data/repos/purchase/debitnote_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';
import 'package:erp/features/auth/data/repos/stock/product_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DebitnoteCubitState {}

class DebitnoteCubitLoading extends DebitnoteCubitState {}

class DebitnoteCubitError extends DebitnoteCubitState {
  final String message;
  DebitnoteCubitError(this.message);
}

class DebitnoteCubitLoaded extends DebitnoteCubitState {
  final List<DebitNote> invoices;
  final List<DebitNote> filteredInvoices;
  final DebitNote? selectedInvoice; // Store selected invoice separately
  final Map<int, String> productNames;
  final Map<int, String> supplierNames;

  DebitnoteCubitLoaded(
    this.invoices, {
    List<DebitNote>? filteredInvoices,
    this.selectedInvoice,
    required this.productNames,
    required this.supplierNames,
  }) : filteredInvoices = filteredInvoices ?? invoices;
}

class DebitnoteCubit extends Cubit<DebitnoteCubitState> {
  final DebitnoteRepo _repository;
  List<DebitNote> _allInvoices = [];

  DebitnoteCubit(this._repository) : super(DebitnoteCubitLoading());

  Future<void> fetchDebitnoteCubits() async {
    if (_allInvoices.isNotEmpty) {
      emit(DebitnoteCubitLoaded(_allInvoices, productNames: {}, supplierNames: {}));
      return;
    }
    emit(DebitnoteCubitLoading());
    try {
      _allInvoices = await _repository.fetchDebitnoteRepos();
      emit(DebitnoteCubitLoaded(_allInvoices, productNames: {}, supplierNames: {}));
    } catch (e) {
      emit(DebitnoteCubitError('Failed to load purchase invoices: $e'));
    }
  }

  void resetSelectedInvoice() {
    if (state is DebitnoteCubitLoaded) {
      final currentState = state as DebitnoteCubitLoaded;
      emit(DebitnoteCubitLoaded(
         productNames: {}, supplierNames: {},
        currentState.invoices,
        filteredInvoices: currentState.filteredInvoices,
        selectedInvoice: null, // Reset selected invoice
      ));
    }
  }

  void searchDebitnoteCubits(String query) {
    resetSelectedInvoice();
    if (state is DebitnoteCubitLoaded) {
      final currentState = state as DebitnoteCubitLoaded;
      final filteredInvoices = query.isEmpty
          ? _allInvoices
          : _allInvoices
              .where((invoice) =>
                  invoice.debitNoteId.toString().contains(query) ||
                  invoice.totalAmount.toString().contains(query))
              .toList();
      emit(DebitnoteCubitLoaded(
         productNames: {}, supplierNames: {},
        _allInvoices,
        filteredInvoices: filteredInvoices,
        selectedInvoice: currentState.selectedInvoice, // Keep selected invoice
      ));
    }
  }

  Future<void> fetchDebitnoteCubitById(int id) async {
    print('Fetching invoice by ID: $id');

    try {
      final fetchedInvoice = await _repository.fetchDebitnoteRepoById(id);

      if (state is DebitnoteCubitLoaded) {
        final currentState = state as DebitnoteCubitLoaded;
         final productNames = await fetchProductNamesForInvoice(fetchedInvoice);
      final supplierNames = await fetchsupplierNamesForInvoice(fetchedInvoice);

        // ✅ Keep the original list and update only the selected invoice
        emit(DebitnoteCubitLoaded(
          productNames: productNames,
          supplierNames: supplierNames,
          currentState.invoices,
          filteredInvoices: currentState.filteredInvoices,
          selectedInvoice:
              fetchedInvoice, // Store the fetched invoice separately
        ));
      }
    } catch (e) {
      emit(DebitnoteCubitError('Failed to load purchase invoice: $e'));
    }
  }
  Future<Map<int, String>> fetchsupplierNamesForInvoice(
      DebitNote invoice) async {
    final supplierNames = <int, String>{};
    final supplierRepo = SupplierRepository();

    for (var item in _allInvoices) {
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
  Future<Map<int, String>> fetchProductNamesForInvoice(
      DebitNote invoice) async {
    final productNames = <int, String>{};
    final productRepo = ProductRepository();

    for (var item in invoice.debitNoteItemsDto) {
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

}
