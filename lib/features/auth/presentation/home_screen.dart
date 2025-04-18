import 'package:erp/Core/Helper/active_modules.dart';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/presentation/accounts/accounts_screen.dart';
import 'package:erp/features/auth/presentation/accounts/assests_screen.dart';
import 'package:erp/features/auth/presentation/accounts/daily.dart';
import 'package:erp/features/auth/presentation/clients/clients.dart';
import 'package:erp/features/auth/presentation/finance/banks_ui.dart';
import 'package:erp/features/auth/presentation/finance/expences.dart';
import 'package:erp/features/auth/presentation/finance/recipt.dart';
import 'package:erp/features/auth/presentation/login_page.dart';
import 'package:erp/features/auth/presentation/purchase/debitnote.dart';
import 'package:erp/features/auth/presentation/purchase/purchase_invoice.dart';
import 'package:erp/features/auth/presentation/purchase/purchase_invoicerefund.dart';
import 'package:erp/features/auth/presentation/purchase/supplier.dart';
import 'package:erp/features/auth/presentation/sales/quotation_screen.dart';
import 'package:erp/features/auth/presentation/sales/recuringinvoice_screen.dart';
import 'package:erp/features/auth/presentation/sales/salesinvoice_screen.dart';
import 'package:erp/features/auth/presentation/stock/products.dart';
import 'package:erp/features/auth/presentation/stock/price_list_screen.dart';
import 'package:erp/features/auth/presentation/stock/warehouse_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    ProductsScreen(),
    PriceListScreen(),
    WarehouseScreen(),
    AccountsScreen(),
    AssetsScreen(),
    JournalEntryScreen(),
    CustomerScreen(),
    PurchaseInvoiceScreen(),
    PurchaseInvoicerefundScreen(),
    DebitNoteScreen(),
    SupplierScreen(),
    ExpenseScreen(),
    ReceiptScreen(),
    BankAccountScreen(),
    SalesInvoiceScreen(),
    RecurringInvoiceScreen(),
    QuotationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black12,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ERP App', style: TextStyle(color: Colors.white)),
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildModernDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: RepaintBoundary(
            child: _screens[_selectedIndex],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: const Color.fromARGB(255, 23, 22, 22),
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  //if (ActiveModules.activeModules[8] == 1)
                  _buildModuleTile(
                    title: 'Warehouse',
                    icon: Icons.warehouse_outlined,
                    children: [
                      _buildSubModuleTile(
                        title: 'Products',
                        icon: Icons.inventory_2_outlined,
                        onTap: () => _onItemTapped(0),
                      ),
                      _buildSubModuleTile(
                        title: 'Price List',
                        icon: Icons.price_change_outlined,
                        onTap: () => _onItemTapped(1),
                      ),
                      _buildSubModuleTile(
                        title: 'Warehouse',
                        icon: Icons.warehouse,
                        onTap: () => _onItemTapped(2),
                      ),
                    ],
                  ),
                  // if (ActiveModules.activeModules[2] == 1)
                  _buildModuleTile(
                    title: 'Accounts',
                    icon: Icons.account_balance_outlined,
                    children: [
                      _buildSubModuleTile(
                        title: 'Accounts',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => _onItemTapped(3),
                      ),
                      _buildSubModuleTile(
                        title: 'Assets',
                        icon: Icons.assessment_outlined,
                        onTap: () => _onItemTapped(4),
                      ),
                      _buildSubModuleTile(
                        title: 'Daily Entries',
                        icon: Icons.assessment_outlined,
                        onTap: () => _onItemTapped(5),
                      ),
                    ],
                  ),
                  _buildModuleTile(
                    title: 'clients',
                    icon: Icons.person_2_outlined,
                    children: [
                      _buildSubModuleTile(
                        title: 'clients',
                        icon: Icons.receipt_outlined,
                        onTap: () => _onItemTapped(6),
                      ),
                    ],
                  ),
                  //  if (ActiveModules.activeModules[9] == 1)
                  _buildModuleTile(
                    title: 'Purchase',
                    icon: Icons.shop,
                    children: [
                      _buildSubModuleTile(
                        title: 'Purchase Invoices',
                        icon: Icons.receipt_outlined,
                        onTap: () => _onItemTapped(7),
                      ),
                      _buildSubModuleTile(
                        title: 'Purchase return Invoices',
                        icon: Icons.shop_sharp,
                        onTap: () => _onItemTapped(8),
                      ),
                      _buildSubModuleTile(
                        title: 'Debit Note',
                        icon: Icons.credit_card,
                        onTap: () => _onItemTapped(9),
                      ),
                      _buildSubModuleTile(
                        title: 'Supplier',
                        icon: Icons.support,
                        onTap: () => _onItemTapped(10),
                      ),
                    ],
                  ),
                  //    if (ActiveModules.activeModules[7] == 1)
                  _buildModuleTile(
                    title: 'Finance',
                    icon: Icons.attach_money,
                    children: [
                      _buildSubModuleTile(
                        title: 'Expenses',
                        icon: Icons.money_off,
                        onTap: () => _onItemTapped(11),
                      ),
                      _buildSubModuleTile(
                        title: 'Recipts',
                        icon: Icons.receipt_long,
                        onTap: () => _onItemTapped(12),
                      ),
                      _buildSubModuleTile(
                        title: 'Banks',
                        icon: Icons.balance,
                        onTap: () => _onItemTapped(13),
                      ),
                    ],
                  ),
                  //    if (ActiveModules.activeModules[3] == 1)
                  _buildModuleTile(
                    title: 'Sales',
                    icon: Icons.sell_rounded,
                    children: [
                      _buildSubModuleTile(
                        title: 'sales Invoices',
                        icon: Icons.receipt_sharp,
                        onTap: () => _onItemTapped(14),
                      ),
                      _buildSubModuleTile(
                        title: 'sales recuring Invoices',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => _onItemTapped(15),
                      ),
                      _buildSubModuleTile(
                        title: 'Quotation',
                        icon: Icons.credit_card,
                        onTap: () => _onItemTapped(16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
              ),
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(95, 71, 67, 67),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ERP App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(8),
          Text(
            'Manage your business efficiently',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      leading: Icon(icon, color: Colors.white),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      childrenPadding: const EdgeInsets.only(left: 24),
      children: children,
    );
  }

  Widget _buildSubModuleTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400]),
      title:
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text(
        'Logout',
        style: TextStyle(color: Colors.redAccent),
      ),
      onTap: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          await TokenStorage.clearToken();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        }
      },
    );
  }

  static int exampleMethod() {
    int result = 0;
    for (int i = 0; i <= 9; i++) {
      if (ActiveModules.activeModules[i] == 1) {
        result = i;
        break;
      }
    }
    return result;
  }
}
