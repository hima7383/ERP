import 'package:erp/features/auth/data/entities/finanse/recipt_entity.dart';
import 'package:erp/features/auth/logic/finance/recipt_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        title: const Text('Receipts', style: TextStyle(color: Colors.white)),
      ),
      body: BlocListener<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptLoaded && state.selectedReceipt != null) {
            _showReceiptDetailsPopup(context, state.selectedReceipt!);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by Code, Amount, Treasury, or Date',
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (query) {
                  context.read<ReceiptCubit>().searchReceipts(query);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<ReceiptCubit, ReceiptState>(
                builder: (context, state) {
                  if (state is ReceiptLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    ));
                  } else if (state is ReceiptError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is ReceiptLoaded) {
                    final receipts = state.filteredReceipts;
                    if (receipts.isEmpty) {
                      return const Center(
                          child: Text(
                        'No receipts found',
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ReceiptCubit>().fetchReceipts();
                      },
                      child: ListView.builder(
                        itemCount: receipts.length,
                        itemBuilder: (context, index) {
                          final receipt = receipts[index];
                          return Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ListTile(
                              title: Text(
                                'Receipt #${receipt.codeNumber}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Amount: ${receipt.amount} ${receipt.currency}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: ${receipt.date.toString().split(' ')[0]}',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.info_outline,
                                  color: Colors.blue),
                              onTap: () {
                                context
                                    .read<ReceiptCubit>()
                                    .fetchReceiptById(receipt.id);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Center(
                      child: Text(
                    'No data found',
                    style: TextStyle(color: Colors.white),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDetailsPopup(BuildContext context, ReceiptDetails receipt) {
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
                    'Receipt #${receipt.codeNumber}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${receipt.date.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[400],
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Treasury:', receipt.treasury, isSmallScreen),
                  _buildInfoRow('Amount:',
                      '${receipt.amount} ${receipt.currency}', isSmallScreen),
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receipt.description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white70,
                      fontFamily: 'Roboto',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (receipt.multiAccReceiptItems.isNotEmpty) ...[
                    Text(
                      'Multi-Account Receipt Items:',
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
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(1.5),
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
                                _buildTableHeader('Tax', isSmallScreen),
                                _buildTableHeader('Amount', isSmallScreen),
                                _buildTableHeader('Tax Amount', isSmallScreen),
                              ],
                            ),
                            ...receipt.multiAccReceiptItems.map((item) {
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
                                      '${item.tax}%', isSmallScreen),
                                  _buildTableCell(
                                      '${item.amount}', isSmallScreen),
                                  _buildTableCell(
                                      '${item.taxAmount}', isSmallScreen),
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
            color: Colors.white70,
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
          color: Colors.white70,
          fontSize: isSmallScreen ? 13 : 15,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
