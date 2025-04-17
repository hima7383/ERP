import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/data/entities/sales/quotation_entity.dart';
import 'package:erp/features/auth/data/repos/clients/clients_repo.dart';
import 'package:erp/features/auth/data/repos/sales/quotation_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class QuotationState {}

class QuotationLoading extends QuotationState {}

class QuotationError extends QuotationState {
  final String message;
  final bool isRecoverable;

   QuotationError(this.message, {this.isRecoverable = true});
}
class QuotationLoadingById extends QuotationState {
  final QuotationLoaded? previousState;

   QuotationLoadingById([this.previousState]);
} // New loading state for fetching by ID

class QuotationLoaded extends QuotationState {
  final List<Quotation> quotations;
  final List<Quotation> filteredQuotations;
  final Quotation? selectedQuotation;
  final Map<int, String> productNames;
  final Map<int, String> customerNames;
  final Set<int> failedCustomerRequests;

   QuotationLoaded({
    required this.quotations,
    required this.filteredQuotations,
    this.selectedQuotation,
    required this.productNames,
    required this.customerNames,
    required this.failedCustomerRequests,
  });

  QuotationLoaded copyWith({
    List<Quotation>? quotations,
    List<Quotation>? filteredQuotations,
    Quotation? selectedQuotation,
    Map<int, String>? productNames,
    Map<int, String>? customerNames,
    Set<int>? failedCustomerRequests,
  }) {
    return QuotationLoaded(
      quotations: quotations ?? this.quotations,
      filteredQuotations: filteredQuotations ?? this.filteredQuotations,
      selectedQuotation: selectedQuotation ?? this.selectedQuotation,
      productNames: productNames ?? this.productNames,
      customerNames: customerNames ?? this.customerNames,
      failedCustomerRequests: failedCustomerRequests ?? this.failedCustomerRequests,
    );
  }
}

class QuotationCubit extends Cubit<QuotationState> {
  final QuotationRepository _quotationRepo;
  final CustomerRepository _customerRepo;
  final int _maxRetryAttempts = 2;
  final Duration _retryDelay = const Duration(seconds: 1);

  List<Quotation> _allQuotations = [];
  final Map<int, String> _customerNames = {};
  final Map<int, String> _productNames = {};
  final Set<int> _pendingCustomerRequests = {};
  final Set<int> _failedCustomerRequests = {};

  QuotationCubit(this._quotationRepo, this._customerRepo) 
      : super(QuotationLoading());

  Future<void> fetchQuotations() async {
    emit(QuotationLoading());
    try {
      _allQuotations = await _quotationRepo.fetchQuotations();
      await _fetchAllCustomerNames();
      emit(QuotationLoaded(
        quotations: _allQuotations,
        filteredQuotations: _allQuotations,
        productNames: _productNames,
        customerNames: _customerNames,
        failedCustomerRequests: _failedCustomerRequests,
      ));
    } catch (e) {
      emit(QuotationError('Failed to load quotations: ${e.toString()}',
          isRecoverable: false));
    }
  }

  Future<void> _fetchAllCustomerNames() async {
    final futures = <Future>[];
    _failedCustomerRequests.clear();

    final customerIds = _allQuotations
        .map((quotation) => quotation.customerId)
        .toSet()
        .where((id) => !_customerNames.containsKey(id))
        .toList();

    for (final customerId in customerIds) {
      futures.add(_fetchCustomerNameWithRetry(customerId));
    }

    await Future.wait(futures);
  }

  Future<void> _fetchCustomerNameWithRetry(int customerId, {int attempt = 0}) async {
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
      final details = await _customerRepo.fetchCustomerDetails(customerId, type);
      _updateCustomerNameCache(customerId, type, details);
    } finally {
      _pendingCustomerRequests.remove(customerId);
    }
  }

  void _updateCustomerNameCache(int customerId, String type, CustomerDetails details) {
    try {
      final name = type == 'Commercial'
          ? details.fullName
          : details.contacts.isNotEmpty
              ? '${details.contacts.first.firstName} ${details.contacts.first.lastName}'
                  .trim()
              : 'Customer $customerId';

      _customerNames[customerId] = name.isNotEmpty ? name : 'Customer $customerId';
    } catch (e) {
      _customerNames[customerId] = 'Customer $customerId';
    }
  }

  Future<void> fetchQuotationById(int id) async {
    print("working on it");
  if (state is! QuotationLoaded) return;
  final currentState = state as QuotationLoaded;

  // Only emit a new state if we're actually loading new data
  emit(QuotationLoadingById(currentState)); // Clear previous selection

  try {
    final quotation = await _quotationRepo.fetchQuotationById(id);
    final productNames = await _fetchProductNamesForQuotation(quotation);
    await _fetchCustomerNameWithRetry(quotation.customerId);
    
    emit(currentState.copyWith(
      selectedQuotation: quotation,
      productNames: productNames,
      customerNames: _customerNames,
      failedCustomerRequests: _failedCustomerRequests,
    ));
  } catch (e) {
    emit(QuotationError('Failed to load quotation: ${e.toString()}'));
    emit(currentState); // Revert to previous state
  }
}

  Future<Map<int, String>> _fetchProductNamesForQuotation(Quotation quotation) async {
    final productNames = <int, String>{};
    if (quotation.items == null) return productNames;

    for (var item in quotation.items!) {
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

  void resetSelectedQuotation() {
    if (state is QuotationLoaded) {
      final currentState = state as QuotationLoaded;
      emit(QuotationLoaded(quotations: currentState.quotations, filteredQuotations:currentState.filteredQuotations, productNames:currentState.productNames, customerNames:currentState.customerNames, failedCustomerRequests:currentState.failedCustomerRequests, selectedQuotation: null));
    }
  }

  void searchQuotations(String query) {
    resetSelectedQuotation();
    if (state is! QuotationLoaded) return;

    final currentState = state as QuotationLoaded;
    final filtered = query.isEmpty
        ? _allQuotations
        : _allQuotations.where((quotation) {
            final customerName = _customerNames[quotation.customerId]?.toLowerCase() ?? '';
            return quotation.quotationId.toString().contains(query) ||
                customerName.contains(query.toLowerCase()) ||
                quotation.grandTotal.toString().contains(query) ||
                quotation.statusText.toLowerCase().contains(query.toLowerCase());
          }).toList();

    emit(currentState.copyWith(
      filteredQuotations: filtered,
      selectedQuotation: null,
    ));
  }

  Future<void> retryFailedCustomerRequests() async {
    if (state is! QuotationLoaded) return;

    final failedIds = _failedCustomerRequests.toList();
    _failedCustomerRequests.clear();

    for (final customerId in failedIds) {
      await _fetchCustomerNameWithRetry(customerId);
    }

    if (state is QuotationLoaded) {
      final updatedState = state as QuotationLoaded;
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