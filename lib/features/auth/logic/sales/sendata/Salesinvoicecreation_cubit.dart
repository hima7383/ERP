// --- sales_invoice_state.dart ---
import 'package:equatable/equatable.dart';
import 'package:erp/features/auth/data/entities/sales/sendata/salesinvoicecreate_entity.dart';
import 'package:erp/features/auth/data/repos/sales/sendata/salesinvoicecreate_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SalesInvoiceState extends Equatable {
  const SalesInvoiceState();

  @override
  List<Object?> get props => [];
}

class SalesInvoiceInitial extends SalesInvoiceState {}

class SalesInvoiceLoading extends SalesInvoiceState {}

class SalesInvoiceSuccess extends SalesInvoiceState {
   // Optionally include data returned from API if needed
   // final dynamic successData;
   // const SalesInvoiceSuccess({this.successData});
   // @override List<Object?> get props => [successData];
}

class SalesInvoiceFailure extends SalesInvoiceState {
  final String error;

  const SalesInvoiceFailure(this.error);

  @override
  List<Object?> get props => [error];
}


// --- sales_invoice_cubit.dart ---

class SalesInvoiceCubitcreate extends Cubit<SalesInvoiceState> {
  final SalesInvoiceRepositorycreate _repository;

  SalesInvoiceCubitcreate(this._repository) : super(SalesInvoiceInitial());

  Future<void> submitInvoice(InvoiceCreateDTO invoiceData) async {
    emit(SalesInvoiceLoading());
    try {
      await _repository.createInvoice(invoiceData);
      emit(SalesInvoiceSuccess());
    } catch (e) {
      emit(SalesInvoiceFailure(e.toString()));
    }
  }

  // Optional: Method to reset state if needed after success/failure shown
  void resetState() {
     emit(SalesInvoiceInitial());
  }
}