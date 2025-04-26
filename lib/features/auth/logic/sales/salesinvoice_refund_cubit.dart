import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/data/entities/sales/salesinvoice_refund_entiy.dart';
import 'package:erp/features/auth/data/repos/clients/clients_repo.dart';
import 'package:erp/features/auth/data/repos/sales/salesinvoice_refund_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SalesInvoiceRefundState {}

class SalesInvoiceLoading extends SalesInvoiceRefundState {}

class SalesInvoiceError extends SalesInvoiceRefundState {
  final String message;
  final bool isRecoverable;

  SalesInvoiceError(this.message, {this.isRecoverable = true});
}
class SalesInvoiceLoadingById extends SalesInvoiceRefundState {
  final SalesInvoiceLoaded? previousState;

  SalesInvoiceLoadingById([this.previousState]);
} // New loading state for fetching by ID

class SalesInvoiceLoaded extends SalesInvoiceRefundState {
  final List<SalesInvoiceRefund> invoices;
  final List<SalesInvoiceRefund> filteredInvoices;
  final SalesInvoiceRefund? selectedInvoice;
  final Map<int, String> productNames;
  final Map<int, String> customerNames;
  final Set<int> failedCustomerRequests;

  SalesInvoiceLoaded({
    required this.invoices,
    required this.filteredInvoices,
    this.selectedInvoice,
    required this.productNames,
    required this.customerNames,
    required this.failedCustomerRequests,
  });

  SalesInvoiceLoaded copyWith({
    List<SalesInvoiceRefund>? invoices,
    List<SalesInvoiceRefund>? filteredInvoices,
    SalesInvoiceRefund? selectedInvoice,
    Map<int, String>? productNames,
    Map<int, String>? customerNames,
    Set<int>? failedCustomerRequests,
  }) {
    return SalesInvoiceLoaded(
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

class SalesInvoiceRefundCubit extends Cubit<SalesInvoiceRefundState> {
  final RefundInvoiceRepository _salesRepo;
  final CustomerRepository _customerRepo;
  final int _maxRetryAttempts = 2;
  final Duration _retryDelay = const Duration(seconds: 1);

  List<SalesInvoiceRefund> _allInvoices = [];
  final Map<int, String> _customerNames = {};
  final Map<int, String> _productNames = {};
  final Set<int> _pendingCustomerRequests = {};
  final Set<int> _failedCustomerRequests = {};

  SalesInvoiceRefundCubit(this._salesRepo, this._customerRepo)
      : super(SalesInvoiceLoading());

  Future<void> fetchSalesInvoices() async {
    emit(SalesInvoiceLoading());
    try {
      _allInvoices = await _salesRepo.fetchRefundInvoices();
      await _fetchAllCustomerNames();
      emit(SalesInvoiceLoaded(
        invoices: _allInvoices,
        filteredInvoices: _allInvoices,
        productNames: _productNames,
        customerNames: _customerNames,
        failedCustomerRequests: _failedCustomerRequests,
      ));
    } catch (e) {
      emit(SalesInvoiceError('Failed to load sales invoices: ${e.toString()}',
          isRecoverable: false));
    }
  }

  Future<void> _fetchAllCustomerNames() async {
    final futures = <Future>[];
    _failedCustomerRequests.clear();

    // Get unique customer IDs from invoices
    final customerIds = _allInvoices
        .map((invoice) => invoice.customerID)
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
        debugPrint(
            'Failed to fetch name for customer $customerId after $attempt attempts: $e');
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
              : 'Individual Customer $customerId';

      _customerNames[customerId] =
          name.isNotEmpty ? name : 'Customer $customerId';
    } catch (e) {
      debugPrint('Error updating name cache for customer $customerId: $e');
      _customerNames[customerId] = 'Customer $customerId';
    }
  }

  Future<void> fetchSalesInvoiceById(int id) async {
    if (state is! SalesInvoiceLoaded) return;
    final currentState = state as SalesInvoiceLoaded;

    emit(SalesInvoiceLoadingById(currentState)); // Emit loading state with previous state

    try {
      final invoice = await _salesRepo.fetchRefundInvoiceDetails(id);
      final productNames = await _fetchProductNamesForInvoice(invoice);
      await _fetchCustomerNameWithRetry(invoice.customerID);

      emit(currentState.copyWith(
        selectedInvoice: invoice,
        productNames: productNames,
        customerNames: _customerNames,
        failedCustomerRequests: _failedCustomerRequests,
      ));
    } catch (e) {
      emit(
          SalesInvoiceError('Failed to load invoice details: ${e.toString()}'));
      emit(currentState); // Revert to previous state after showing error
    }
  }

  Future<Map<int, String>> _fetchProductNamesForInvoice(
      SalesInvoiceRefund invoice) async {
    final productNames = <int, String>{};
    if (invoice.invoiceItems == null) return productNames;

    for (var item in invoice.invoiceItems!) {
      if (_productNames.containsKey(item.productId)) {
        productNames[item.productId] = _productNames[item.productId]!;
        continue;
      }

      try {
        // Assuming you have a ProductRepository with fetchProductById method
        // final product = await productRepo.fetchProductById(item.productId);
        // productNames[item.productId] = product.name;
        // _productNames[item.productId] = product.name;

        // Temporary placeholder - implement your product name fetching logic
        productNames[item.productId] = 'Product ${item.productId}';
        _productNames[item.productId] = 'Product ${item.productId}';
      } catch (e) {
        debugPrint('Failed to fetch product name for ${item.productId}: $e');
        productNames[item.productId] = 'Product ${item.productId}';
      }
    }

    return productNames;
  }

  void resetSelectedInvoice() {
    if (state is SalesInvoiceLoaded) {
      final currentState = state as SalesInvoiceLoaded;
      emit(SalesInvoiceLoaded(
          invoices: currentState.invoices,
          filteredInvoices: currentState.filteredInvoices,
          productNames: currentState.productNames,
          customerNames: currentState.customerNames,
          failedCustomerRequests: currentState.failedCustomerRequests,
          selectedInvoice: null));
    }
  }

  void searchSalesInvoices(String query) {
    resetSelectedInvoice();
    if (state is! SalesInvoiceLoaded) return;

    final currentState = state as SalesInvoiceLoaded;
    final filtered = query.isEmpty
        ? _allInvoices
        : _allInvoices.where((invoice) {
            final customerName =
                _customerNames[invoice.customerID]?.toLowerCase() ?? '';
            return invoice.refundInvoiceId.toString().contains(query) ||
                customerName.contains(query.toLowerCase()) ||
                invoice.total.toString().contains(query) ||
                invoice.paymentStatus
                    .toLowerCase()
                    .contains(query.toLowerCase());
          }).toList();

    emit(currentState.copyWith(
      filteredInvoices: filtered,
      selectedInvoice: null, // Clear selection when searching
    ));
  }

  Future<void> retryFailedCustomerRequests() async {
    if (state is! SalesInvoiceLoaded) return;
    final currentState = state as SalesInvoiceLoaded;

    emit(currentState.copyWith(
      customerNames: _customerNames,
      failedCustomerRequests: _failedCustomerRequests,
    ));

    final failedIds = _failedCustomerRequests.toList();
    _failedCustomerRequests.clear();

    for (final customerId in failedIds) {
      await _fetchCustomerNameWithRetry(customerId);
    }

    if (state is SalesInvoiceLoaded) {
      final updatedState = state as SalesInvoiceLoaded;
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
