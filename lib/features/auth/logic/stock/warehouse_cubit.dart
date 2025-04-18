import 'package:equatable/equatable.dart';
import 'package:erp/features/auth/data/entities/stock/warehouse.dart';
import 'package:erp/features/auth/data/repos/stock/warehouse_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Add equatable package for easier state comparison

abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

// Initial state before anything is loaded
class WarehouseInitial extends WarehouseState {}

// State while loading data from the repository
class WarehouseLoading extends WarehouseState {}
class WarehouseLoadingById extends WarehouseState {
  final WarehouseListLoaded? previousState; // Holds the previous state for reference

  const WarehouseLoadingById([this.previousState]);

  @override
  List<Object?> get props => [previousState];
}
// State representing an error during data fetching
class WarehouseError extends WarehouseState {
  final String message;
  final bool isRecoverable; // Flag to suggest if a retry is feasible

  const WarehouseError(this.message, {this.isRecoverable = true});

  @override
  List<Object?> get props => [message, isRecoverable];
}

// State when the list of warehouses is successfully loaded
class WarehouseListLoaded extends WarehouseState {
  final List<Warehouse> warehouses; // The complete list from the repo
  final List<Warehouse> filteredWarehouses; // The list to display (after search/filter)
  final Warehouse? selectedWarehouse; // Holds details when an item is selected for popup

  const WarehouseListLoaded({
    required this.warehouses,
    required this.filteredWarehouses,
    this.selectedWarehouse,
  });

  // Helper method to create a copy of the state with potential modifications
  WarehouseListLoaded copyWith({
    List<Warehouse>? warehouses,
    List<Warehouse>? filteredWarehouses,
    Warehouse? selectedWarehouse, // Use Object? to allow setting it explicitly to null
    bool forceSelectedWarehouseNull = false, // Helper flag
  }) {
    return WarehouseListLoaded(
      warehouses: warehouses ?? this.warehouses,
      filteredWarehouses: filteredWarehouses ?? this.filteredWarehouses,
      // Handle null assignment correctly
      selectedWarehouse: forceSelectedWarehouseNull ? null : selectedWarehouse ?? this.selectedWarehouse,
    );
  }

  @override
  List<Object?> get props => [warehouses, filteredWarehouses, selectedWarehouse];
}


class WarehouseCubit extends Cubit<WarehouseState> {
  final WarehouseRepository _repository;
  List<Warehouse> allWarehouses = []; // Cache for the full list

  WarehouseCubit(this._repository) : super(WarehouseInitial()) {
    // Fetch data immediately when the Cubit is created
    fetchWarehouses();
  }

  // Fetches the initial list of warehouses
  Future<void> fetchWarehouses() async {
    // Don't emit loading if already loaded to allow background refresh feel
    if (state is! WarehouseListLoaded) {
       emit(WarehouseLoading());
    }
    try {
      allWarehouses = await _repository.fetchWarehouses();
      emit(WarehouseListLoaded(
        warehouses: allWarehouses,
        filteredWarehouses: allWarehouses, // Initially, filtered list is the full list
        selectedWarehouse: null, // No selection initially
      ));
    } catch (e) {
      emit(WarehouseError('Failed to load warehouses: ${e.toString()}'));
    }
  }

  // Fetches full details for a specific warehouse (triggered by user tap)
  Future<void> fetchWarehouseById(int warehouseId) async {
    // Ensure we have a loaded list state to work with
    if (state is! WarehouseListLoaded) {
       return;
    }
    final currentState = state as WarehouseListLoaded;
    emit(WarehouseLoadingById(currentState)); // Emit loading state with previous state

    // Optional: Indicate loading details, perhaps by setting selectedWarehouse briefly?
    // emit(currentState.copyWith(selectedWarehouse: null)); // Clear previous selection immediately

    try {
      final details = await _repository.fetchWarehouseDetails(warehouseId);
      // Emit the loaded state with the selected warehouse details populated
      emit(currentState.copyWith(selectedWarehouse: details));
    } catch (e) {
      // Emit error state
      emit(WarehouseError('Failed to load warehouse details: ${e.toString()}'));
      // IMPORTANT: Re-emit the *previous* valid state so the UI doesn't get stuck on an error
      // preventing the user from seeing the list.
      emit(currentState.copyWith(forceSelectedWarehouseNull: true)); // Ensure selectedWarehouse is cleared after error
    }
  }

  // Clears the selected warehouse details (used after showing the popup)
  void resetSelectedWarehouse() {
    if (state is WarehouseListLoaded) {
      final currentState = state as WarehouseListLoaded;
      emit(currentState.copyWith(forceSelectedWarehouseNull: true));
    }
  }

  // Filters the displayed list based on user search query
  void searchWarehouses(String query) {
    if (state is! WarehouseListLoaded) {
      return;
    }
    final currentState = state as WarehouseListLoaded;

    final filtered = query.isEmpty
        ? allWarehouses // Show all if query is empty
        : allWarehouses.where((warehouse) {
            final queryLower = query.toLowerCase();
            final nameMatch = warehouse.warehouseName.toLowerCase().contains(queryLower);
            final addressMatch = warehouse.address?.toLowerCase().contains(queryLower) ?? false;
            final idMatch = warehouse.warehouseId.toString().contains(queryLower);
            return nameMatch || addressMatch || idMatch;
          }).toList();

    // Emit the state update with the filtered list and clear any previous selection
    emit(currentState.copyWith(
      filteredWarehouses: filtered,
      forceSelectedWarehouseNull: true, // Clear selection on search
    ));
  }

   // Optional: Method for pull-to-refresh that re-fetches the list
   Future<void> refreshWarehouses() async {
     await fetchWarehouses();
   }
}