import 'dart:async';
import 'package:erp/features/auth/data/entities/finanse/banks_entity.dart';
import 'package:erp/features/auth/data/repos/finance/banks_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BankAccountState {
  const BankAccountState();
}

class BankAccountLoading extends BankAccountState {
  const BankAccountLoading();
}

class BankAccountError extends BankAccountState {
  final String message;
  final bool isRecoverable;

  const BankAccountError(this.message, {this.isRecoverable = true});
}

class BankAccountLoadingById extends BankAccountState {
  final List<BankAccountSummary> bankAccounts;
  final List<BankAccountSummary> filteredBankAccounts;
  final Map<int, String> nameCache;
  final Set<int> failedRequests;

  const BankAccountLoadingById({
    required this.bankAccounts,
    required this.filteredBankAccounts,
    required this.nameCache,
    required this.failedRequests,
  });

  factory BankAccountLoadingById.fromPreviousState(BankAccountListLoaded state) {
    return BankAccountLoadingById(
      bankAccounts: state.bankAccounts,
      filteredBankAccounts: state.filteredBankAccounts,
      nameCache: state.nameCache,
      failedRequests: state.failedRequests,
    );
  }
}

class BankAccountListLoaded extends BankAccountState {
  final List<BankAccountSummary> bankAccounts;
  final List<BankAccountSummary> filteredBankAccounts;
  final BankAccount? selectedBankAccount;
  final Map<int, String> nameCache;
  final Set<int> failedRequests;

  const BankAccountListLoaded({
    required this.bankAccounts,
    required this.filteredBankAccounts,
    this.selectedBankAccount,
    required this.nameCache,
    required this.failedRequests,
  });

  BankAccountListLoaded copyWith({
    List<BankAccountSummary>? bankAccounts,
    List<BankAccountSummary>? filteredBankAccounts,
    BankAccount? selectedBankAccount,
    Map<int, String>? nameCache,
    Set<int>? failedRequests,
  }) {
    return BankAccountListLoaded(
      bankAccounts: bankAccounts ?? this.bankAccounts,
      filteredBankAccounts: filteredBankAccounts ?? this.filteredBankAccounts,
      selectedBankAccount: selectedBankAccount ?? this.selectedBankAccount,
      nameCache: nameCache ?? this.nameCache,
      failedRequests: failedRequests ?? this.failedRequests,
    );
  }
}

class BankAccountCubit extends Cubit<BankAccountState> {
  final BankAccountRepository _repository;
  final int _maxRetryAttempts = 2;
  final Duration _retryDelay = const Duration(seconds: 1);

  List<BankAccountSummary> _allBankAccounts = [];
  final Map<int, String> _nameCache = {};
  final Set<int> _pendingRequests = {};
  final Set<int> _failedRequests = {};

  BankAccountCubit(this._repository) : super(const BankAccountLoading());

  Future<void> fetchBankAccounts() async {
    emit(const BankAccountLoading());
    try {
      _allBankAccounts = await _repository.fetchBankAccounts();
      await _fetchAllDetails();
      emit(BankAccountListLoaded(
        bankAccounts: _allBankAccounts,
        filteredBankAccounts: _allBankAccounts,
        nameCache: _nameCache,
        failedRequests: _failedRequests,
      ));
    } catch (e) {
      emit(BankAccountError('Failed to load bank accounts: ${e.toString()}',
          isRecoverable: false));
    }
  }

  Future<void> _fetchAllDetails() async {
    final futures = <Future>[];
    _failedRequests.clear();

    for (final account in _allBankAccounts) {
      final accountId = account.bankAccountID;
      if (_nameCache.containsKey(accountId)) continue;

      futures.add(_fetchDetailsWithRetry(accountId));
    }

    await Future.wait(futures);
  }

  Future<void> _fetchDetailsWithRetry(int accountId, {int attempt = 0}) async {
    if (_nameCache.containsKey(accountId)) return;

    try {
      await _fetchAndCacheDetails(accountId);
      _failedRequests.remove(accountId);
    } catch (e) {
      if (attempt < _maxRetryAttempts) {
        await Future.delayed(_retryDelay);
        await _fetchDetailsWithRetry(accountId, attempt: attempt + 1);
      } else {
        _failedRequests.add(accountId);
        debugPrint(
            'Failed to fetch details for bank account $accountId after $attempt attempts: $e');
        _nameCache[accountId] = 'Bank Account $accountId';
      }
    }
  }

  Future<void> _fetchAndCacheDetails(int accountId) async {
    if (_pendingRequests.contains(accountId)) return;

    _pendingRequests.add(accountId);
    try {
      final details = await _repository.fetchBankAccountDetails(accountId);
      _updateNameCache(accountId, details);
    } finally {
      _pendingRequests.remove(accountId);
    }
  }

  Future<void> fetchBankAccountById(int accountId) async {
    if (state is! BankAccountListLoaded) return;
    final currentState = state as BankAccountListLoaded;

    emit(BankAccountLoadingById.fromPreviousState(currentState));

    try {
      final details = await _repository.fetchBankAccountDetails(accountId);
      _updateNameCache(accountId, details);
      _failedRequests.remove(accountId);

      emit(currentState.copyWith(
        selectedBankAccount: details,
        nameCache: _nameCache,
        failedRequests: _failedRequests,
      ));
    } catch (e) {
      _failedRequests.add(accountId);
      emit(currentState.copyWith(
        failedRequests: _failedRequests,
      ));
      emit(BankAccountError(
          'Failed to load bank account details: ${e.toString()}'));
      emit(currentState); // Revert to previous state after showing error
    }
  }

  void resetSelectedBankAccount() {
    if (state is BankAccountListLoaded) {
      final currentState = state as BankAccountListLoaded;
      emit(BankAccountListLoaded(
        failedRequests: currentState.failedRequests,
        bankAccounts: currentState.bankAccounts,
        nameCache: currentState.nameCache,
        filteredBankAccounts: currentState.filteredBankAccounts,
      ));
    }
  }

  void searchBankAccounts(String query) {
    resetSelectedBankAccount();
    if (state is! BankAccountListLoaded) return;

    final currentState = state as BankAccountListLoaded;
    final filtered = query.isEmpty
        ? _allBankAccounts
        : _allBankAccounts.where((account) {
            final cachedName =
                _nameCache[account.bankAccountID]?.toLowerCase() ?? '';
            return account.bankAccountID.toString().contains(query) ||
                cachedName.contains(query.toLowerCase()) ||
                account.accountNumber.contains(query) ||
                account.bankName.toLowerCase().contains(query.toLowerCase()) ||
                account.accountHolderName
                    .toLowerCase()
                    .contains(query.toLowerCase());
          }).toList();

    emit(currentState.copyWith(
      filteredBankAccounts: filtered,
      selectedBankAccount: null, // Clear selection when searching
    ));
  }

  void _updateNameCache(int accountId, BankAccount details) {
    try {
      final name = '${details.accountHolderName} - ${details.bankName}';
      _nameCache[accountId] =
          name.isNotEmpty ? name : 'Bank Account $accountId';
    } catch (e) {
      debugPrint('Error updating name cache for bank account $accountId: $e');
      _nameCache[accountId] = 'Bank Account $accountId';
    }
  }

  Future<void> retryFailedRequests() async {
    if (state is! BankAccountListLoaded) return;
    final currentState = state as BankAccountListLoaded;

    emit(currentState.copyWith(
      nameCache: _nameCache,
      failedRequests: _failedRequests,
    ));

    final failedIds = _failedRequests.toList();
    _failedRequests.clear();

    for (final accountId in failedIds) {
      await _fetchDetailsWithRetry(accountId);
    }

    if (state is BankAccountListLoaded) {
      final updatedState = state as BankAccountListLoaded;
      emit(updatedState.copyWith(
        nameCache: _nameCache,
        failedRequests: _failedRequests,
      ));
    }
  }

  String? getCachedName(int accountId) {
    return _nameCache[accountId];
  }

  bool isRequestFailed(int accountId) {
    return _failedRequests.contains(accountId);
  }

  // Additional bank account specific functionality
  void filterByStatus(int? status) {
    if (state is! BankAccountListLoaded) return;
    final currentState = state as BankAccountListLoaded;

    final filtered = status == null
        ? _allBankAccounts
        : _allBankAccounts
            .where((account) => account.status == status)
            .toList();

    emit(currentState.copyWith(
      filteredBankAccounts: filtered,
      selectedBankAccount: null,
    ));
  }

  void filterByPermission(int? permissionType) {
    if (state is! BankAccountListLoaded) return;
    final currentState = state as BankAccountListLoaded;

    final filtered = permissionType == null
        ? _allBankAccounts
        : _allBankAccounts.where((account) {
            return account.depositPermission == permissionType ||
                account.withdrawPermission == permissionType;
          }).toList();

    emit(currentState.copyWith(
      filteredBankAccounts: filtered,
      selectedBankAccount: null,
    ));
  }
}
