import 'package:dio/dio.dart';
import 'package:erp/Core/widgets/rout_observer.dart';
import 'package:erp/features/auth/data/repos/accounts/accounts_repo.dart';
import 'package:erp/features/auth/data/repos/accounts/daily.dart';
import 'package:erp/features/auth/data/repos/activemodules/active_modules_repo.dart';
import 'package:erp/features/auth/data/repos/clients/clients_repo.dart';
import 'package:erp/features/auth/data/repos/finance/banks_repo.dart';
import 'package:erp/features/auth/data/repos/finance/expencses_repo.dart';
import 'package:erp/features/auth/data/repos/finance/recipt_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/debitnote_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/purchase_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/purchaserefund_repo.dart';
import 'package:erp/features/auth/data/repos/purchase/supplier_repo.dart';
import 'package:erp/features/auth/data/repos/sales/quotation_repo.dart';
import 'package:erp/features/auth/data/repos/sales/recuringinvoices_repo.dart';
import 'package:erp/features/auth/data/repos/sales/salesInvoices_repo.dart';
import 'package:erp/features/auth/data/repos/sales/salesinvoice_refund_repo.dart';
import 'package:erp/features/auth/data/repos/sales/sendata/salesinvoicecreate_repo.dart';
import 'package:erp/features/auth/data/repos/stock/product_repo.dart';
import 'package:erp/features/auth/data/repos/stock/warehouse_permesions.dart';
import 'package:erp/features/auth/data/repos/stock/warehouse_repo.dart';
import 'package:erp/features/auth/logic/Auth/login_cubit.dart';
import 'package:erp/features/auth/logic/accounts/accounts_cubit.dart';
import 'package:erp/features/auth/logic/accounts/assests_cubit.dart';
import 'package:erp/features/auth/logic/accounts/daily.dart';
import 'package:erp/features/auth/logic/clients/clients_cubit.dart';
import 'package:erp/features/auth/logic/connecting/connect_cubit.dart';
import 'package:erp/features/auth/logic/finance/banks_cubit.dart';
import 'package:erp/features/auth/logic/finance/expences_cubit.dart';
import 'package:erp/features/auth/logic/finance/recipt_cubit.dart';
import 'package:erp/features/auth/logic/login_bloc.dart';
import 'package:erp/features/auth/logic/purchase/debitnote_cubit.dart';
import 'package:erp/features/auth/logic/purchase/purchase_cubit.dart';
import 'package:erp/features/auth/logic/purchase/purchaserefund_cubit.dart';
import 'package:erp/features/auth/logic/purchase/supplier_cubit.dart';
import 'package:erp/features/auth/logic/sales/quotation_cubit.dart';
import 'package:erp/features/auth/logic/sales/recuringinvoice_cubit.dart';
import 'package:erp/features/auth/logic/sales/salesInvoice_cubit.dart';
import 'package:erp/features/auth/logic/sales/salesinvoice_refund_cubit.dart';
import 'package:erp/features/auth/logic/sales/sendata/Salesinvoicecreation_cubit.dart';
import 'package:erp/features/auth/logic/stock/product_bloc.dart';
import 'package:erp/features/auth/logic/stock/price_list_cubit.dart';
import 'package:erp/features/auth/logic/stock/warehouse_cubit.dart';
import 'package:erp/features/auth/presentation/connection/connection_screen.dart';
import 'package:erp/features/auth/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityCubit>(create: (_) => ConnectivityCubit()),
          // Product Cubit
          BlocProvider(
            create: (context) =>
                ProductCubit(ProductRepository())..fetchProducts(),
          ),
          // Permissions Cubit
          BlocProvider(
            create: (_) => PriceListCubit(PriceListRepository())
              ..fetchPriceLists(),
              
          ),
          // Warehouse Cubit
          BlocProvider(
            create: (_) =>
                WarehouseCubit(WarehouseRepository())..fetchWarehouses(),
          ),
          // Accounts Cubit
          BlocProvider(
            create: (_) =>
                AccountsCubit(AccountsRepository())..fetchMainAccounts(),
          ),
          // Assets Cubit
          BlocProvider(
            create: (_) => AssetsCubit(AccountsRepository())..fetchAssets(),
          ),
          // Journal Entry Cubit
          BlocProvider(
            create: (context) => JournalEntryCubit(JournalEntryRepository())
              ..fetchJournalEntries(),
          ),
          // Customer Cubit
          BlocProvider(
            create: (_) =>
                CustomerCubit(CustomerRepository())..fetchCustomers(),
          ),
          // Purchase Invoice Cubit
          BlocProvider(
            create: (_) => PurchaseInvoiceCubit(PurchaseInvoiceRepository())
              ..fetchPurchaseInvoices(),
          ),
          BlocProvider(
            create: (_) =>
                PurchaseInvoicerefundCubit(PurchaseInvoicerefundRepository())
                  ..fetchPurchaseInvoices(),
          ),
          BlocProvider(
            create: (_) =>
                DebitnoteCubit(DebitnoteRepo())..fetchDebitnoteCubits(),
          ),
          BlocProvider(
            create: (_) =>
                SupplierCubit(SupplierRepository())..fetchSuppliers(),
          ),
          BlocProvider(
            create: (_) => ExpenseCubit(ExpenseRepository())..fetchExpenses(),
          ),
          BlocProvider(
            create: (_) => ReceiptCubit(ReceiptRepository())..fetchReceipts(),
          ),
          BlocProvider(
            create: (_) =>
                BankAccountCubit(BankAccountRepository())..fetchBankAccounts(),
          ),
           BlocProvider(
            create: (_) =>
                SalesInvoiceRefundCubit(RefundInvoiceRepository(),CustomerRepository())..fetchSalesInvoices(),
          ),
          BlocProvider(
            create: (_) => SalesInvoiceCubit(
                SalesInvoiceRepository(), CustomerRepository())
              ..fetchSalesInvoices(),
          ),
          BlocProvider(
            create: (_) => RecurringInvoiceCubit(
                RecurringInvoiceRepository(), CustomerRepository())
              ..fetchRecurringInvoices(),
          ),
          BlocProvider(
            create: (_) => AuthCubit()..checkAuthStatus(),
          ),
          BlocProvider(
            create: (_) =>
                QuotationCubit(QuotationRepository(), CustomerRepository())
                  ..fetchQuotations(),
          ),
          BlocProvider(create: (_) => LoginBloc(CompanyRepository())),
          BlocProvider(create: (_)=>SalesInvoiceCubitcreate(SalesInvoiceRepositoryImpl(Dio()))),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          navigatorObservers: [routeObserver],
          home: NetworkAwareApp(
            child: SplashScreen(),
          ),  
        ));
  }
}
