import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/finanse/recipt_entity.dart';
import 'package:erp/features/auth/logic/finance/recipt_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReceiptCubit, ReceiptState>(
      listener: (context, state) {
        if (state is ReceiptError) {
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
                            onPressed: () => context.read<ReceiptCubit>().fetchReceipts(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
        }
        if (state is ReceiptLoaded && state.selectedReceipt != null) {
          _showReceiptDetailsPopup(context, state.selectedReceipt!);
          context.read<ReceiptCubit>().resetSelectedReceipt();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            title: const Text(
              'Receipts',
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

  Widget _buildBody(BuildContext context, ReceiptState state) {
    if (state is ReceiptLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    } else if (state is ReceiptError) {
      return Center(
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
                            onPressed: () => context.read<ReceiptCubit>().fetchReceipts(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
    } else if (state is ReceiptLoadingById || state is ReceiptLoaded) {
      final receipts = (state is ReceiptLoaded)
          ? state.filteredReceipts
          : (state as ReceiptLoadingById).previousState is ReceiptLoaded
              ? (state.previousState as ReceiptLoaded).filteredReceipts
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
                    hintText: 'Search by Code, Amount, Treasury, or Date',
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
                    context.read<ReceiptCubit>().searchReceipts(query);
                  },
                ),
              ),
              Expanded(
                child: receipts.isEmpty
                    ? Center(
                        child: Text(
                          'No receipts found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ReceiptCubit>().fetchReceipts();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: receipts.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final receipt = receipts[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                      style:
                                          const TextStyle(color: Colors.white),
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
                      ),
              ),
            ],
          ),
          if (state is ReceiptLoadingById)
            const ModernLoadingOverlay(msg: "Receipt"),
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
