import 'package:erp/features/auth/data/entities/finanse/recipt_entity.dart';
import 'package:erp/features/auth/data/repos/finance/recipt_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReceiptState {}

class ReceiptLoading extends ReceiptState {}

class ReceiptError extends ReceiptState {
  final String message;
  ReceiptError(this.message);
}

class ReceiptLoadingById extends ReceiptState {
  final ReceiptLoaded? previousState;
  ReceiptLoadingById([this.previousState]);
}

class ReceiptLoaded extends ReceiptState {
  final List<Receipt> receipts;
  final List<Receipt> filteredReceipts;
  final ReceiptDetails? selectedReceipt;

  ReceiptLoaded(
    this.receipts, {
    List<Receipt>? filteredReceipts,
    this.selectedReceipt,
  }) : filteredReceipts = filteredReceipts ?? receipts;
}

class ReceiptCubit extends Cubit<ReceiptState> {
  final ReceiptRepository _repository;
  List<Receipt> _allReceipts = [];

  ReceiptCubit(this._repository) : super(ReceiptLoading());

  Future<void> fetchReceipts() async {
    if (_allReceipts.isNotEmpty) {
      emit(ReceiptLoaded(
        _allReceipts,
      ));
      return;
    }
    emit(ReceiptLoading());
    try {
      _allReceipts = await _repository.fetchReceipts();
      emit(ReceiptLoaded(
        _allReceipts,
      ));
    } catch (e) {
      emit(ReceiptError('Failed to load receipts: $e'));
    }
  }

  void resetSelectedReceipt() {
    if (state is ReceiptLoaded) {
      final currentState = state as ReceiptLoaded;
      emit(ReceiptLoaded(
        currentState.receipts,
        filteredReceipts: currentState.filteredReceipts,
        selectedReceipt: null,
      ));
    }
  }

  void searchReceipts(String query) {
    resetSelectedReceipt();
    if (state is ReceiptLoaded) {
      final currentState = state as ReceiptLoaded;
      final filtered = query.isEmpty
          ? _allReceipts
          : _allReceipts
              .where((receipt) =>
                  receipt.id.toString().contains(query) ||
                  receipt.codeNumber
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  receipt.amount.toString().contains(query))
              .toList();
      emit(ReceiptLoaded(
        _allReceipts,
        filteredReceipts: filtered,
        selectedReceipt: currentState.selectedReceipt,
      ));
    }
  }

  Future<void> fetchReceiptById(int id) async {
    if (state is! ReceiptLoaded) return;
    final currentState = state as ReceiptLoaded;
    emit(ReceiptLoadingById(currentState));
    try {
      final fetchedReceipt = await _repository.fetchReceiptDetails(id);
      for (var receipt in _allReceipts) {
        if (receipt.id == fetchedReceipt.id) {
          break;
        }
      }

      emit(ReceiptLoaded(
        currentState.receipts,
        filteredReceipts: currentState.filteredReceipts,
        selectedReceipt: fetchedReceipt,
      ));
    } catch (e) {
      emit(ReceiptError('Failed to load receipt: $e'));
    }
  }
}
