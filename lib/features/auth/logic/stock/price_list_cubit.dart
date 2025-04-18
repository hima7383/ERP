import 'package:equatable/equatable.dart';
import 'package:erp/features/auth/data/entities/stock/warehouse_permesion.dart';
import 'package:erp/features/auth/data/repos/stock/warehouse_permesions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PriceListState extends Equatable {
  const PriceListState();

  @override
  List<Object?> get props => [];
}

class PriceListInitial extends PriceListState {}

class PriceListLoading extends PriceListState {}

class PriceListError extends PriceListState {
  final String message;
  final bool isRecoverable;

  const PriceListError(this.message, {this.isRecoverable = true});

  @override
  List<Object?> get props => [message, isRecoverable];
}
class PriceListLoadingById extends PriceListState {
  final PriceListLoaded? previousState;

  const PriceListLoadingById([this.previousState]);

  @override
  List<Object?> get props => [previousState];
}

class PriceListLoaded extends PriceListState {
  final List<PriceListSummary> priceLists;       // Full list of summaries
  final List<PriceListSummary> filteredPriceLists; // Filtered list for display
  final PriceListDetails? selectedPriceListDetails; // Holds details for popup

  const PriceListLoaded({
    required this.priceLists,
    required this.filteredPriceLists,
    this.selectedPriceListDetails,
  });

  PriceListLoaded copyWith({
    List<PriceListSummary>? priceLists,
    List<PriceListSummary>? filteredPriceLists,
    PriceListDetails? selectedPriceListDetails,
    bool forceSelectedDetailsNull = false,
  }) {
    return PriceListLoaded(
      priceLists: priceLists ?? this.priceLists,
      filteredPriceLists: filteredPriceLists ?? this.filteredPriceLists,
      selectedPriceListDetails: forceSelectedDetailsNull ? null : selectedPriceListDetails ?? this.selectedPriceListDetails,
    );
  }

  @override
  List<Object?> get props => [priceLists, filteredPriceLists, selectedPriceListDetails];
}


class PriceListCubit extends Cubit<PriceListState> {
  final PriceListRepository _repository;
  List<PriceListSummary> allPriceLists = []; // Cache for the full list of summaries

  PriceListCubit(this._repository) : super(PriceListInitial()) {
    fetchPriceLists();
  }

  Future<void> fetchPriceLists() async {
    if (state is! PriceListLoaded) { // Avoid showing loading over existing list during refresh
      emit(PriceListLoading());
    }
    try {
      allPriceLists = await _repository.fetchPriceLists();
      emit(PriceListLoaded(
        priceLists: allPriceLists,
        filteredPriceLists: allPriceLists,
        selectedPriceListDetails: null, // Reset selection on list load/refresh
      ));
    } catch (e) {
      emit(PriceListError('Failed to load price lists: ${e.toString()}'));
    }
  }

  Future<void> fetchPriceListById(int priceListId) async {
    if (state is! PriceListLoaded) {
       return;
    }
    final currentState = state as PriceListLoaded;
    emit(PriceListLoadingById(currentState)); // Show loading state for details

    // Optional: Indicate loading details? Can be handled by UI showing progress on tap.

    try {
      final details = await _repository.fetchPriceListDetails(priceListId);
      emit(currentState.copyWith(selectedPriceListDetails: details));
    } catch (e) {
      emit(PriceListError('Failed to load price list details: ${e.toString()}'));
      emit(currentState.copyWith(forceSelectedDetailsNull: true)); // Revert to previous good state, clear selection
    }
  }

  void resetSelectedPriceList() {
    if (state is PriceListLoaded) {
      final currentState = state as PriceListLoaded;
      emit(currentState.copyWith(forceSelectedDetailsNull: true));
    }
  }

  void searchPriceLists(String query) {
     if (state is! PriceListLoaded) {
      return;
    }
    final currentState = state as PriceListLoaded;

    final filtered = query.isEmpty
        ? allPriceLists
        : allPriceLists.where((priceList) {
            final queryLower = query.toLowerCase();
            final nameMatch = priceList.priceListName.toLowerCase().contains(queryLower);
            final idMatch = priceList.priceListId.toString().contains(queryLower);
            return nameMatch || idMatch;
          }).toList();

    emit(currentState.copyWith(
      filteredPriceLists: filtered,
      forceSelectedDetailsNull: true, // Clear selection on search
    ));
  }

  Future<void> refreshPriceLists() async {
    // Simple refresh just refetches the list
    await fetchPriceLists();
  }
}