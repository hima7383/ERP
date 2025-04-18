import 'dart:async';
import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/data/repos/clients/clients_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CustomerState {
  const CustomerState();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoadingById extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final Map<int, String> nameCache;
  final Set<int> failedRequests;

  const CustomerLoadingById({
    required this.customers,
    required this.filteredCustomers,
    required this.nameCache,
    required this.failedRequests,
  });

  factory CustomerLoadingById.fromPreviousState(CustomerListLoaded state) {
    return CustomerLoadingById(
      customers: state.customers,
      filteredCustomers: state.filteredCustomers,
      nameCache: state.nameCache,
      failedRequests: state.failedRequests,
    );
  }
}

class CustomerError extends CustomerState {
  final String message;
  final bool isRecoverable;

  const CustomerError(this.message, {this.isRecoverable = true});
}

class CustomerListLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final CustomerDetails? selectedCustomer;
  final Map<int, String> nameCache;
  final Set<int> failedRequests;

  const CustomerListLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.selectedCustomer,
    required this.nameCache,
    required this.failedRequests,
  });

  CustomerListLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    CustomerDetails? selectedCustomer,
    Map<int, String>? nameCache,
    Set<int>? failedRequests,
  }) {
    return CustomerListLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      nameCache: nameCache ?? this.nameCache,
      failedRequests: failedRequests ?? this.failedRequests,
    );
  }
}

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;
  final int _maxRetryAttempts = 2;
  final Duration _retryDelay = const Duration(seconds: 1);

  List<Customer> _allCustomers = [];
  final Map<int, String> _nameCache = {};
  final Set<int> _pendingNameRequests = {};
  final Set<int> _failedRequests = {};

  CustomerCubit(this._repository) : super(const CustomerLoading());

  Future<void> fetchCustomers() async {
    emit(const CustomerLoading());
    try {
      _allCustomers = await _repository.fetchCustomers();
      await _fetchAllNames();
      emit(CustomerListLoaded(
        customers: _allCustomers,
        filteredCustomers: _allCustomers,
        nameCache: _nameCache,
        failedRequests: _failedRequests,
      ));
    } catch (e) {
      emit(CustomerError('Failed to load customers: ${e.toString()}',
          isRecoverable: false));
    }
  }

  Future<void> _fetchAllNames() async {
    final futures = <Future>[];
    _failedRequests.clear();

    for (final customer in _allCustomers) {
      final customerId = customer.customerId;
      if (_nameCache.containsKey(customerId)) continue;

      futures.add(_fetchNameWithRetry(customerId));
    }

    await Future.wait(futures);
  }

  Future<void> _fetchNameWithRetry(int customerId, {int attempt = 0}) async {
    if (_nameCache.containsKey(customerId)) return;

    try {
      await _fetchAndCacheName(customerId);
      _failedRequests.remove(customerId);
    } catch (e) {
      if (attempt < _maxRetryAttempts) {
        await Future.delayed(_retryDelay);
        await _fetchNameWithRetry(customerId, attempt: attempt + 1);
      } else {
        _failedRequests.add(customerId);
        debugPrint(
            'Failed to fetch name for customer $customerId after $attempt attempts: $e');
        _nameCache[customerId] = 'Customer $customerId';
      }
    }
  }

  Future<void> _fetchAndCacheName(int customerId) async {
    if (_pendingNameRequests.contains(customerId)) return;

    _pendingNameRequests.add(customerId);
    try {
      final type = await _repository.getCustomerType(customerId);
      final details = await _repository.fetchCustomerDetails(customerId, type);
      _updateNameCache(customerId, type, details);
    } finally {
      _pendingNameRequests.remove(customerId);
    }
  }

  Future<void> fetchCustomerById(int customerId) async {
    if (state is! CustomerListLoaded) return;
    final currentState = state as CustomerListLoaded;

    emit(CustomerLoadingById.fromPreviousState(currentState));

    try {
      final type = await _repository.getCustomerType(customerId);
      final details = await _repository.fetchCustomerDetails(customerId, type);
      _updateNameCache(customerId, type, details);
      _failedRequests.remove(customerId);

      emit(currentState.copyWith(
        selectedCustomer: details,
        nameCache: _nameCache,
        failedRequests: _failedRequests,
      ));
    } catch (e) {
      _failedRequests.add(customerId);
      emit(currentState.copyWith(
        failedRequests: _failedRequests,
      ));
      emit(CustomerError('Failed to load customer details: ${e.toString()}'));
      emit(currentState); // Revert to previous state after showing error
    }
  }

  void resetSelectedCustomer() {
    if (state is CustomerListLoaded) {
      final currentState = state as CustomerListLoaded;
      emit(CustomerListLoaded(
        failedRequests: currentState.failedRequests,
        customers: currentState.customers,
        nameCache: currentState.nameCache,
        filteredCustomers: currentState.filteredCustomers,
      ));
    }
  }

  void searchCustomers(String query) {
    resetSelectedCustomer();
    if (state is! CustomerListLoaded) return;

    final currentState = state as CustomerListLoaded;
    final filtered = query.isEmpty
        ? _allCustomers
        : _allCustomers.where((customer) {
            final cachedName =
                _nameCache[customer.customerId]?.toLowerCase() ?? '';
            return customer.customerId.toString().contains(query) ||
                cachedName.contains(query.toLowerCase()) ||
                customer.phoneNumber.contains(query);
          }).toList();

    emit(currentState.copyWith(
      filteredCustomers: filtered,
      selectedCustomer: null, // Clear selection when searching
    ));
  }

  void _updateNameCache(int customerId, String type, CustomerDetails details) {
    try {
      final name = type == 'Commercial'
          ? details.fullName
          : details.contacts.isNotEmpty
              ? '${details.contacts.first.firstName} ${details.contacts.first.lastName}'
                  .trim()
              : 'Individual Customer $customerId';

      _nameCache[customerId] = name.isNotEmpty ? name : 'Customer $customerId';
    } catch (e) {
      debugPrint('Error updating name cache for customer $customerId: $e');
      _nameCache[customerId] = 'Customer $customerId';
    }
  }

  Future<void> retryFailedRequests() async {
    if (state is! CustomerListLoaded) return;
    final currentState = state as CustomerListLoaded;

    emit(currentState.copyWith(
      nameCache: _nameCache,
      failedRequests: _failedRequests,
    ));

    final failedIds = _failedRequests.toList();
    _failedRequests.clear();

    for (final customerId in failedIds) {
      await _fetchNameWithRetry(customerId);
    }

    if (state is CustomerListLoaded) {
      final updatedState = state as CustomerListLoaded;
      emit(updatedState.copyWith(
        nameCache: _nameCache,
        failedRequests: _failedRequests,
      ));
    }
  }

  String? getCachedName(int customerId) {
    return _nameCache[customerId];
  }

  bool isRequestFailed(int customerId) {
    return _failedRequests.contains(customerId);
  }
}
