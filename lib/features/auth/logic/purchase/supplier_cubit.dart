import 'package:erp/features/auth/data/entities/purchase/supplier.dart';
import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierError extends SupplierState {
  final String message;
  SupplierError(this.message);
}

class SupplierLoadingById extends SupplierState {
  final SupplierListLoaded? previousState;
  SupplierLoadingById([this.previousState]);
} // New loading state for fetching by ID

class SupplierListLoaded extends SupplierState {
  final List<Supplier> suppliers;
  final List<Supplier> filteredSuppliers;
  final SupplierData? selectedSupplier;

  SupplierListLoaded(
    this.suppliers, {
    List<Supplier>? filteredSuppliers,
    this.selectedSupplier,
  }) : filteredSuppliers = filteredSuppliers ?? suppliers;
}

class SupplierCubit extends Cubit<SupplierState> {
  final SupplierRepository _repository;
  List<Supplier> _allSuppliers = [];

  SupplierCubit(this._repository) : super(SupplierLoading());

  Future<void> fetchSuppliers() async {
    if (_allSuppliers.isNotEmpty) {
      emit(SupplierListLoaded(_allSuppliers));
      return;
    }

    emit(SupplierLoading());
    try {
      _allSuppliers = await _repository.fetchSuppliers();
      emit(SupplierListLoaded(_allSuppliers));
    } catch (e) {
      emit(SupplierError('Failed to load suppliers: $e'));
    }
  }

  void resetSelectedSupplier() {
    if (state is SupplierListLoaded) {
      final currentState = state as SupplierListLoaded;
      emit(SupplierListLoaded(
        currentState.suppliers,
        filteredSuppliers: currentState.filteredSuppliers,
        selectedSupplier: null,
      ));
    }
  }

  void searchSuppliers(String query) {
    resetSelectedSupplier();
    if (state is SupplierListLoaded) {
      final currentState = state as SupplierListLoaded;
      final filteredSuppliers = query.isEmpty
          ? _allSuppliers
          : _allSuppliers
              .where((supplier) =>
                  supplier.supplierId.toString().contains(query) ||
                  supplier.supplierName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  supplier.accountId.toString().contains(query))
              .toList();
      emit(SupplierListLoaded(
        _allSuppliers,
        filteredSuppliers: filteredSuppliers,
        selectedSupplier: currentState.selectedSupplier,
      ));
    }
  }

  Future<void> fetchSupplierById(int id) async {
    if (state is! SupplierListLoaded) return;
    final currentState = state as SupplierListLoaded;
    emit(SupplierLoadingById(currentState)); // Emit loading state
    try {
      final fetchedSupplier = await _repository.fetchSupplierById(id);
      emit(SupplierListLoaded(
        currentState.suppliers,
        filteredSuppliers: currentState.filteredSuppliers,
        selectedSupplier: fetchedSupplier,
      ));
    } catch (e) {
      emit(SupplierError('Failed to load supplier details: $e'));
    }
  }
}
