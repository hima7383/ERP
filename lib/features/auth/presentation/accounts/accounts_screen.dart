import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp/features/auth/logic/accounts/accounts_cubit.dart';
import 'package:erp/features/auth/data/entities/accounts/accounts.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    context.read<AccountsCubit>().fetchMainAccounts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Chart of Accounts',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            // Modern search bar
            _buildSearchBar(context),
            const SizedBox(height: 12),
            // Account list with improved spacing
            Expanded(
              child: BlocBuilder<AccountsCubit, List<Account>>(
                builder: (context, accounts) {
                  if (accounts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    );
                  }
                  return AccountTree(accounts: accounts);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search accounts...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
      onChanged: (query) => context.read<AccountsCubit>().searchAccounts(query),
    );
  }
}

class AccountTree extends StatelessWidget {
  final List<Account> accounts;

  const AccountTree({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AccountsCubit>().fetchMainAccounts();
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) => _buildAccountTile(accounts[index]),
      ),
    );
  }

  Widget _buildAccountTile(Account account) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: account.childAccounts.isEmpty
              ? _buildSimpleTile(account)
              : _buildExpandableTile(account),
        ),
      ),
    );
  }

  Widget _buildSimpleTile(Account account) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      minLeadingWidth: 8,
      leading: Container(
        width: 4,
        height: 24,
        decoration: BoxDecoration(
          color: _getBalanceColor(account.balance),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Text(
        account.accountName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: Text(
        account.balance.toStringAsFixed(2),
        style: TextStyle(
          color: _getBalanceColor(account.balance),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExpandableTile(Account account) {
    return ExpansionTile(
      title: Text(
        account.accountName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        account.balance.toStringAsFixed(2),
        style: TextStyle(
          color: _getBalanceColor(account.balance),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: Colors.grey[400],
      collapsedIconColor: Colors.grey[400],
      tilePadding: const EdgeInsets.only(left: 12, right: 8),
      childrenPadding: const EdgeInsets.only(left: 24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      collapsedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      children: account.childAccounts
          .map((child) => _buildAccountTile(child))
          .toList(),
    );
  }

  Color _getBalanceColor(double balance) {
    return balance >= 0 ? Colors.greenAccent[400]! : Colors.redAccent[400]!;
  }
}
