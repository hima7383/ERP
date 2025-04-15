import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp/features/auth/data/repos/accounts/accounts_repo.dart';
import 'package:erp/features/auth/data/entities/accounts/accounts.dart';

class AccountsCubit extends Cubit<List<Account>> {
  final AccountsRepository repository;
  List<Account> _allAccounts = []; // Store all accounts for search functionality

  AccountsCubit(this.repository) : super([]);

  // Fetch main accounts (primary accounts)
  Future<void> fetchMainAccounts() async {
    try {
      _allAccounts = await repository.fetchMainAccounts();
      emit(_allAccounts); // Emit the list of primary accounts
    } catch (e) {
      print('Error fetching main accounts: $e');
      emit([]); // Emit an empty list in case of error
    }
  }

  // Search accounts by name
  void searchAccounts(String query) {
    if (query.isEmpty) {
      emit(_allAccounts); // Reset to all accounts if the query is empty
    } else {
      final filteredAccounts = _allAccounts
          .where((account) =>
              account.accountName.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(filteredAccounts); // Emit the filtered accounts
    }
  }

  // Open an account (primary or secondary)
  /*Future<void> openAccount(String accountId) async {
    try {
      final accountType = await repository.getAccountTypeById(accountId);
      if (accountType == '0') {
        // Assuming '0' represents a primary account
        final primaryAccount = await repository.getPrimaryAccountById(accountId);
        emit([primaryAccount]); // Emit the primary account with its child accounts
      } else {
        // Handle secondary account (cannot be opened)
        emit([]); // Or show a message to the user
      }
    } catch (e) {
      print('Error opening account: $e');
      emit([]); // Emit an empty list in case of error
    }
  }*/
}