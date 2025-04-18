import 'package:erp/features/auth/data/entities/finanse/expenses_entity.dart';
import 'package:erp/features/auth/data/repos/finance/expencses_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

abstract class ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

class ExpenseLoadingById extends ExpenseState {
  final ExpenseLoaded? previousState;
  ExpenseLoadingById([this.previousState]);
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final ExpenseDetails? selectedExpense;
  final Map<int, String> supplierNames;

  ExpenseLoaded(
    this.expenses, {
    List<Expense>? filteredExpenses,
    this.selectedExpense,
    required this.supplierNames,
  }) : filteredExpenses = filteredExpenses ?? expenses;
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;
  List<Expense> _allExpenses = [];

  ExpenseCubit(this._repository) : super(ExpenseLoading());

  Future<void> fetchExpenses() async {
    if (_allExpenses.isNotEmpty) {
      emit(ExpenseLoaded(
        supplierNames: {},
        _allExpenses,
      ));
      return;
    }
    emit(ExpenseLoading());
    try {
      _allExpenses = await _repository.fetchExpenses();
      emit(ExpenseLoaded(
        supplierNames: {},
        _allExpenses,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  void resetSelectedExpense() {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      emit(ExpenseLoaded(
        supplierNames: {},
        currentState.expenses,
        filteredExpenses: currentState.filteredExpenses,
        selectedExpense: null,
      ));
    }
  }

  Future<Map<int, String>> fetchSupplierNamesForExpense(Expense expense) async {
    final supplierNames = <int, String>{};
    final supplierRepo = SupplierRepository();

    try {
      final suppliers = await supplierRepo.fetchSuppliers();
      for (var supp in suppliers) {
        if (supp.supplierId == expense.supplierId) {
          supplierNames[expense.id] = supp.supplierName;
        }
      }
    } catch (e) {
      debugPrint('Error fetching supplier: $e');
      supplierNames[expense.supplierId!] = 'Supplier #${expense.supplierId}';
    }

    return supplierNames;
  }

  void searchExpenses(String query) {
    resetSelectedExpense();
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final filtered = query.isEmpty
          ? _allExpenses
          : _allExpenses
              .where((expense) =>
                  expense.id.toString().contains(query) ||
                  expense.codeNumber
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  (currentState.supplierNames[expense.supplierId]
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ??
                      false) ||
                  expense.amount.toString().contains(query))
              .toList();
      emit(ExpenseLoaded(
        supplierNames: {},
        _allExpenses,
        filteredExpenses: filtered,
        selectedExpense: currentState.selectedExpense,
      ));
    }
  }

  Future<void> fetchExpenseById(int id) async {
    if (state is! ExpenseLoaded) return;
    final currentState = state as ExpenseLoaded;
    emit(ExpenseLoadingById(currentState));
    print(state);
    try {
      final fetchedExpense = await _repository.fetchExpenseDetails(id);
      Expense? ok;
      for (var expense in _allExpenses) {
        if (expense.id == fetchedExpense.id) {
          ok = expense;
          break;
        }
      }
      //print(ok);
      final supplierNames = await fetchSupplierNamesForExpense(ok!);

      emit(ExpenseLoaded(
        supplierNames: supplierNames,
        currentState.expenses,
        filteredExpenses: currentState.filteredExpenses,
        selectedExpense: fetchedExpense,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to load expense: $e'));
    }
  }
}
