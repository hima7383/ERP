import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/finanse/banks_entity.dart';
import 'package:erp/features/auth/logic/finance/banks_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  _BankAccountScreenState createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BankAccountCubit, BankAccountState>(
      listener: (context, state) {
        if (state is BankAccountError) {
          Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No internet connection",
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your connection",
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                            ),
                            ),
                            onPressed: () => context.read<BankAccountCubit>().fetchBankAccounts(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
        }
        if (state is BankAccountListLoaded &&
            state.selectedBankAccount != null) {
          _showBankAccountDetailsPopup(context, state.selectedBankAccount!);
          context.read<BankAccountCubit>().resetSelectedBankAccount();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              'Bank Accounts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: () => _showFilterMenu(context),
                tooltip: 'Filter accounts',
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BankAccountState state) {
    if (state is BankAccountLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (state is BankAccountError) {
      return  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No internet connection",
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your connection",
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                            ),
                            ),
                            onPressed: () => context.read<BankAccountCubit>().fetchBankAccounts(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
    } else if (state is BankAccountLoadingById ||
        state is BankAccountListLoaded) {
      final accounts = (state is BankAccountListLoaded)
          ? state.filteredBankAccounts
          : (state as BankAccountLoadingById).filteredBankAccounts;

      final nameCache = (state is BankAccountListLoaded)
          ? state.nameCache
          : (state as BankAccountLoadingById).nameCache;

      return Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search bank accounts...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (query) {
                    context.read<BankAccountCubit>().searchBankAccounts(query);
                  },
                ),
              ),
              Expanded(
                child: accounts.isEmpty
                    ? Center(
                        child: Text(
                          'No bank accounts found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<BankAccountCubit>()
                              .fetchBankAccounts();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            itemCount: accounts.length,
                            separatorBuilder: (context, index) => const Gap(8),
                            itemBuilder: (context, index) {
                              final account = accounts[index];
                              return _BankAccountCard(
                                account: account,
                                nameCache: nameCache,
                                onTap: () => context
                                    .read<BankAccountCubit>()
                                    .fetchBankAccountById(
                                        account.bankAccountID),
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (state is BankAccountLoadingById)
            const ModernLoadingOverlay(msg: "Account"),
        ],
      );
    }
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Accounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              _buildFilterOption(
                context,
                'All Accounts',
                () => context.read<BankAccountCubit>().filterByStatus(null),
              ),
              _buildFilterOption(
                context,
                'Active Accounts',
                () => context.read<BankAccountCubit>().filterByStatus(1),
              ),
              _buildFilterOption(
                context,
                'Inactive Accounts',
                () => context.read<BankAccountCubit>().filterByStatus(0),
              ),
              const Divider(color: Colors.grey),
              _buildFilterOption(
                context,
                'With Deposit Permission',
                () => context.read<BankAccountCubit>().filterByPermission(1),
              ),
              _buildFilterOption(
                context,
                'With Withdraw Permission',
                () => context.read<BankAccountCubit>().filterByPermission(2),
              ),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
      BuildContext context, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showBankAccountDetailsPopup(BuildContext context, BankAccount details) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getDetailAccountColor(details),
                      child: Text(
                        details.accountHolderName.isNotEmpty
                            ? details.accountHolderName[0].toUpperCase()
                            : 'B',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.accountHolderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${details.bankName} • ${details.currency}',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Tabs
              SizedBox(
                height: 48,
                child: Material(
                  color: Colors.grey[900],
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Deposit'),
                      Tab(text: 'Withdraw'),
                      Tab(text: 'Activity'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey[400],
                    indicatorColor: Colors.blue,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                  ),
                ),
              ),

              // Tab Content
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(child: _buildDetailsTab(details)),
                    SingleChildScrollView(
                        child: _buildDepositAccessTab(details)),
                    SingleChildScrollView(
                        child: _buildWithdrawAccessTab(details)),
                    SingleChildScrollView(child: _buildActivityTab(details)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab(BankAccount details) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: 'Bank Name',
            value: details.bankName,
          ),
          _DetailRow(
            label: 'Account Number',
            value: details.accountNumber,
          ),
          _DetailRow(
            label: 'Currency',
            value: details.currency,
          ),
          _DetailRow(
            label: 'Status',
            value: details.status == 1 ? 'Active' : 'Inactive',
            valueColor: details.status == 1 ? Colors.green : Colors.red,
          ),
          _DetailRow(
            label: 'Deposit Permission',
            value: _getPermissionText(details.depositPermission),
            valueColor:
                details.depositPermission == 1 ? Colors.green : Colors.red,
          ),
          _DetailRow(
            label: 'Withdraw Permission',
            value: _getPermissionText(details.withdrawPermission),
            valueColor:
                details.withdrawPermission == 1 ? Colors.green : Colors.red,
          ),
          const Gap(24),
          const Text(
            'Permission Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              _PermissionChip(
                label: 'Deposit',
                isAllowed: details.depositPermission == 1,
              ),
              const Gap(8),
              _PermissionChip(
                label: 'Withdraw',
                isAllowed: details.withdrawPermission == 1,
              ),
            ],
          ),
          const Gap(12),
          Text(
            '${details.employeesWithDepositPermission?.length ?? 0} employees can deposit',
            style: TextStyle(color: Colors.grey[300]),
          ),
          Text(
            '${details.employeesWithWithdrawPermission?.length ?? 0} employees can withdraw',
            style: TextStyle(color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositAccessTab(BankAccount details) {
    final employees = details.employeesWithDepositPermission ?? [];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Employees with Deposit Permission (${employees.length})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (employees.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No employees with deposit permission',
              style: TextStyle(color: Colors.grey[400]),
            ),
          )
        else
          ...employees
              .map((employee) => _EmployeeCard(employee: employee))
              .toList(),
      ],
    );
  }

  Widget _buildWithdrawAccessTab(BankAccount details) {
    final employees = details.employeesWithWithdrawPermission ?? [];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Employees with Withdraw Permission (${employees.length})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (employees.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No employees with withdraw permission',
              style: TextStyle(color: Colors.grey[400]),
            ),
          )
        else
          ...employees
              .map((employee) => _EmployeeCard(employee: employee))
              .toList(),
      ],
    );
  }

  Widget _buildActivityTab(BankAccount details) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Transaction history would appear here',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _getPermissionText(int permission) {
    switch (permission) {
      case 0:
        return 'None';
      case 1:
        return 'Allowed';
      case 2:
        return 'Restricted';
      default:
        return 'Unknown';
    }
  }

  Color _getDetailAccountColor(BankAccount details) {
    if (details.depositPermission == 1 && details.withdrawPermission == 1) {
      return Colors.blue;
    } else if (details.depositPermission == 1) {
      return Colors.green;
    } else if (details.withdrawPermission == 1) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}

class _BankAccountCard extends StatelessWidget {
  final BankAccountSummary account;
  final Map<int, String> nameCache;
  final VoidCallback onTap;

  const _BankAccountCard({
    required this.account,
    required this.nameCache,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getAccountColor(account),
              child: Text(
                account.accountHolderName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameCache[account.bankAccountID] ??
                        'Account #${account.bankAccountID}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    account.bankName,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const Gap(4),
                  Text(
                    '••••${account.accountNumber.substring(account.accountNumber.length - 4)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: account.status == 1
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                account.status == 1 ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: account.status == 1 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccountColor(BankAccountSummary account) {
    if (account.depositPermission == 1 && account.withdrawPermission == 1) {
      return Colors.blue;
    } else if (account.depositPermission == 1) {
      return Colors.green;
    } else if (account.withdrawPermission == 1) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  final bool isAllowed;

  const _PermissionChip({
    required this.label,
    required this.isAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isAllowed
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2),
      side: BorderSide(
        color: isAllowed ? Colors.green : Colors.red,
        width: 1,
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;

  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              '${employee.firstName.substring(0, 1)}${employee.lastName.substring(0, 1)}',
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${employee.firstName} ${employee.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4),
                Text(
                  employee.email,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            employee.country,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
