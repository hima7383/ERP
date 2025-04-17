import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/data/entities/sales/recuringinvoice_entity.dart';
import 'package:erp/features/auth/data/repos/clients/clients_repo.dart';
import 'package:erp/features/auth/data/repos/sales/recuringinvoices_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RecurringInvoiceState {}

class RecurringInvoiceLoading extends RecurringInvoiceState {}

class RecurringInvoiceError extends RecurringInvoiceState {
  final String message;
  final bool isRecoverable;

  RecurringInvoiceError(this.message, {this.isRecoverable = true});
}
class RecurringInvoiceLoadingById extends RecurringInvoiceState {
  final RecurringInvoiceLoaded? previousState;

  RecurringInvoiceLoadingById([this.previousState]);
} // New loading state for fetching by ID

class RecurringInvoiceLoaded extends RecurringInvoiceState {
  final List<RecurringInvoice> invoices;
  final List<RecurringInvoice> filteredInvoices;
  final RecurringInvoice? selectedInvoice;
  final Map<int, String> productNames;
  final Map<int, String> customerNames;
  final Set<int> failedCustomerRequests;

  RecurringInvoiceLoaded({
    required this.invoices,
    required this.filteredInvoices,
    this.selectedInvoice,
    required this.productNames,
    required this.customerNames,
    required this.failedCustomerRequests,
  });

  RecurringInvoiceLoaded copyWith({
    List<RecurringInvoice>? invoices,
    List<RecurringInvoice>? filteredInvoices,
    RecurringInvoice? selectedInvoice,
    Map<int, String>? productNames,
    Map<int, String>? customerNames,
    Set<int>? failedCustomerRequests,
  }) {
    return RecurringInvoiceLoaded(
      invoices: invoices ?? this.invoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
      productNames: productNames ?? this.productNames,
      customerNames: customerNames ?? this.customerNames,
      failedCustomerRequests:
          failedCustomerRequests ?? this.failedCustomerRequests,
    );
  }
}

class RecurringInvoiceCubit extends Cubit<RecurringInvoiceState> {
  final RecurringInvoiceRepository _invoiceRepo;
  final CustomerRepository _customerRepo;
  final int _maxRetryAttempts = 2;
  final Duration _retryDelay = const Duration(seconds: 1);

  List<RecurringInvoice> _allInvoices = [];
  final Map<int, String> _customerNames = {};
  final Map<int, String> _productNames = {};
  final Set<int> _pendingCustomerRequests = {};
  final Set<int> _failedCustomerRequests = {};

  RecurringInvoiceCubit(this._invoiceRepo, this._customerRepo)
      : super(RecurringInvoiceLoading());

  Future<void> fetchRecurringInvoices() async {
    emit(RecurringInvoiceLoading());
    try {
      _allInvoices = await _invoiceRepo.fetchRecurringInvoices();
      await _fetchAllCustomerNames();
      emit(RecurringInvoiceLoaded(
        invoices: _allInvoices,
        filteredInvoices: _allInvoices,
        productNames: _productNames,
        customerNames: _customerNames,
        failedCustomerRequests: _failedCustomerRequests,
      ));
    } catch (e) {
      emit(RecurringInvoiceError(
          'Failed to load recurring invoices: ${e.toString()}',
          isRecoverable: false));
    }
  }

  Future<void> _fetchAllCustomerNames() async {
    final futures = <Future>[];
    _failedCustomerRequests.clear();

    final customerIds = _allInvoices
        .map((invoice) => invoice.customerId)
        .toSet()
        .where((id) => !_customerNames.containsKey(id))
        .toList();

    for (final customerId in customerIds) {
      futures.add(_fetchCustomerNameWithRetry(customerId));
    }

    await Future.wait(futures);
  }

  Future<void> _fetchCustomerNameWithRetry(int customerId,
      {int attempt = 0}) async {
    if (_customerNames.containsKey(customerId)) return;

    try {
      await _fetchAndCacheCustomerName(customerId);
      _failedCustomerRequests.remove(customerId);
    } catch (e) {
      if (attempt < _maxRetryAttempts) {
        await Future.delayed(_retryDelay);
        await _fetchCustomerNameWithRetry(customerId, attempt: attempt + 1);
      } else {
        _failedCustomerRequests.add(customerId);
        debugPrint('Failed to fetch name for customer $customerId: $e');
        _customerNames[customerId] = 'Customer $customerId';
      }
    }
  }

  Future<void> _fetchAndCacheCustomerName(int customerId) async {
    if (_pendingCustomerRequests.contains(customerId)) return;

    _pendingCustomerRequests.add(customerId);
    try {
      final type = await _customerRepo.getCustomerType(customerId);
      final details =
          await _customerRepo.fetchCustomerDetails(customerId, type);
      _updateCustomerNameCache(customerId, type, details);
    } finally {
      _pendingCustomerRequests.remove(customerId);
    }
  }

  void _updateCustomerNameCache(
      int customerId, String type, CustomerDetails details) {
    try {
      final name = type == 'Commercial'
          ? details.fullName
          : details.contacts.isNotEmpty
              ? '${details.contacts.first.firstName} ${details.contacts.first.lastName}'
                  .trim()
              : 'Customer $customerId';

      _customerNames[customerId] =
          name.isNotEmpty ? name : 'Customer $customerId';
    } catch (e) {
      _customerNames[customerId] = 'Customer $customerId';
    }
  }

  Future<void> fetchRecurringInvoiceById(int id) async {
    if (state is! RecurringInvoiceLoaded) return;
    final currentState = state as RecurringInvoiceLoaded;

    emit(
      RecurringInvoiceLoadingById(currentState), // Emit loading state with previous state
    );

    try {
      final invoice = await _invoiceRepo.fetchRecurringInvoiceById(id);
      final productNames = await _fetchProductNamesForInvoice(invoice);
      await _fetchCustomerNameWithRetry(invoice.customerId);

      emit(currentState.copyWith(
        selectedInvoice: invoice,
        productNames: productNames,
        customerNames: _customerNames,
        failedCustomerRequests: _failedCustomerRequests,
      ));
    } catch (e) {
      emit(RecurringInvoiceError('Failed to load invoice: ${e.toString()}'));
      emit(currentState);
    }
  }

  Future<Map<int, String>> _fetchProductNamesForInvoice(
      RecurringInvoice invoice) async {
    final productNames = <int, String>{};
    if (invoice.items == null) return productNames;

    for (var item in invoice.items!) {
      if (_productNames.containsKey(item.productId)) {
        productNames[item.productId] = _productNames[item.productId]!;
        continue;
      }

      try {
        // Implement your product name fetching logic here
        productNames[item.productId] = 'Product ${item.productId}';
        _productNames[item.productId] = 'Product ${item.productId}';
      } catch (e) {
        productNames[item.productId] = 'Product ${item.productId}';
      }
    }

    return productNames;
  }

  void resetSelectedInvoice() {
    if (state is RecurringInvoiceLoaded) {
      final currentState = state as RecurringInvoiceLoaded;
      emit(RecurringInvoiceLoaded(
          invoices: currentState.invoices,
          filteredInvoices: currentState.filteredInvoices,
          productNames: currentState.productNames,
          customerNames: currentState.customerNames,
          failedCustomerRequests: currentState.failedCustomerRequests,
          selectedInvoice: null));
    } else {
      emit(RecurringInvoiceLoading());
    }
  }

  void searchRecurringInvoices(String query) {
    resetSelectedInvoice();
    if (state is! RecurringInvoiceLoaded) return;

    final currentState = state as RecurringInvoiceLoaded;
    final filtered = query.isEmpty
        ? _allInvoices
        : _allInvoices.where((invoice) {
            final customerName =
                _customerNames[invoice.customerId]?.toLowerCase() ?? '';
            return invoice.recurringInvoiceId.toString().contains(query) ||
                customerName.contains(query.toLowerCase());
          }).toList();

    emit(currentState.copyWith(
      filteredInvoices: filtered,
      selectedInvoice: null,
    ));
  }

  Future<void> retryFailedCustomerRequests() async {
    if (state is! RecurringInvoiceLoaded) return;

    final failedIds = _failedCustomerRequests.toList();
    _failedCustomerRequests.clear();

    for (final customerId in failedIds) {
      await _fetchCustomerNameWithRetry(customerId);
    }

    if (state is RecurringInvoiceLoaded) {
      final updatedState = state as RecurringInvoiceLoaded;
      emit(updatedState.copyWith(
        customerNames: _customerNames,
        failedCustomerRequests: _failedCustomerRequests,
      ));
    }
  }

  String? getCachedCustomerName(int customerId) {
    return _customerNames[customerId];
  }

  bool isCustomerRequestFailed(int customerId) {
    return _failedCustomerRequests.contains(customerId);
  }
}
