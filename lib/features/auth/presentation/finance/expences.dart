import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/finanse/expenses_entity.dart';
import 'package:erp/features/auth/logic/finance/expences_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is ExpenseLoaded && state.selectedExpense != null) {
          _showExpenseDetailsPopup(
            context,
            state.selectedExpense!,
            state.supplierNames,
          );
          context.read<ExpenseCubit>().resetSelectedExpense();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            title: const Text(
              'Expenses',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ExpenseState state) {
    if (state is ExpenseLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (state is ExpenseError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is ExpenseLoadingById || state is ExpenseLoaded) {
      final expenses = (state is ExpenseLoaded)
          ? state.filteredExpenses
          : (state as ExpenseLoadingById).previousState is ExpenseLoaded
              ? (state.previousState as ExpenseLoaded).filteredExpenses
              : [];

      return Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, Code or Amount',
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
                  onChanged: (query) {
                    context.read<ExpenseCubit>().searchExpenses(query);
                  },
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ExpenseCubit>().fetchExpenses();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: expenses.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final expense = expenses[index];

                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                title: Text(
                                  '${expense.codeNumber} - ${expense.amount} ${expense.currency}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  expense.date.toString().split(' ')[0],
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                trailing: Text(
                                  expense.treasury,
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                onTap: () => context
                                    .read<ExpenseCubit>()
                                    .fetchExpenseById(expense.id),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is ExpenseLoadingById)
            const ModernLoadingOverlay(msg: "Expense"),
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

  void _showExpenseDetailsPopup(BuildContext context, ExpenseDetails expense,
      Map<int, String> supplierNames) {
    showDialog(
      context: context,
      builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 600;

        return Dialog(
          backgroundColor: Colors.grey[900],
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Expense #${expense.codeNumber}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Amount:',
                      '${expense.amount} ${expense.currency}', isSmallScreen),
                  _buildInfoRow('Date:', expense.date.toString().split(' ')[0],
                      isSmallScreen),
                  _buildInfoRow('Supplier:',
                      supplierNames[expense.id] ?? 'Unknown', isSmallScreen),
                  _buildInfoRow('Treasury:', expense.treasury, isSmallScreen),
                  const SizedBox(height: 16),
                  if (expense.multiAccExpenseItems.isNotEmpty) ...[
                    Text(
                      'Multi-Account Expense Items:',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: isSmallScreen
                              ? MediaQuery.of(context).size.width - 64
                              : 550,
                        ),
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.grey[800]!,
                            width: 1,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.5),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                              children: [
                                _buildTableHeader('Account', isSmallScreen),
                                _buildTableHeader('Amount', isSmallScreen),
                                _buildTableHeader('Tax', isSmallScreen),
                              ],
                            ),
                            ...expense.multiAccExpenseItems.map((item) {
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[800]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                children: [
                                  _buildTableCell(
                                      item.secondaryAccount, isSmallScreen),
                                  _buildTableCell(
                                      '${item.amount}', isSmallScreen),
                                  _buildTableCell(
                                      '${item.tax}%', isSmallScreen),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 16,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 13 : 15,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
