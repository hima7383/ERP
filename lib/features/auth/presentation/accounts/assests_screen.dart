import 'package:erp/features/auth/data/entities/accounts/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp/features/auth/logic/accounts/assests_cubit.dart'; // Contains Cubit, State, Enum

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You might want to fetch initial assets here or rely on RefreshIndicator
    // context.read<AssetsCubit>().fetchAssets();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Asset Management',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        // No actions button here anymore
      ),
      body: BlocListener<AssetsCubit, AssetsState>(
        listener: (context, state) {
          final isSequenceDone = state.sequenceStatus == DataStatus.success ||
              state.sequenceStatus == DataStatus.failure;

          // Dismiss loading dialog ONLY when sequence fetch finishes
          if (isSequenceDone) {
            // Check if a dialog (our loading one) is open and pop it
            // Using a simple check, might need adjustment based on navigation stack complexity
            if (Navigator.of(context).canPop()) {
              // Check if the *current* route is a DialogRoute before popping indiscriminately
              // This is a safer check but requires more context, `canPop` is often sufficient
              // final currentRoute = ModalRoute.of(context);
              // if (currentRoute is DialogRoute) {
              Navigator.of(context).pop();
              // }
            }
          }

          // Handle sequence results AFTER popping dialog
          if (state.sequenceStatus == DataStatus.success) {
            if (state.sequenceNames.isNotEmpty) {
              _showSequenceNamesDialog(
                  context, state.sequenceNames); // Show results popup
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account sequence is empty.'),
                  backgroundColor: Colors.blueGrey,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else if (state.sequenceStatus == DataStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Check your internet connection and try again'),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 3),
              ),
            );
          }
          // Handle asset loading failure (optional separate message)
          else if (state.assetsStatus == DataStatus.failure &&
              state.errorMessage != null &&
              state.sequenceStatus != DataStatus.loading) {
            // Avoid showing asset error if sequence loading is in progress or just finished
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Check your internet connection and try again'),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              _buildSearchBar(context),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AssetsCubit, AssetsState>(
                  buildWhen: (previous, current) =>
                      previous.assetsStatus != current.assetsStatus ||
                      previous.displayedAssets != current.displayedAssets,
                  builder: (context, state) {
                    // Handle Asset Loading State
                    if (state.assetsStatus == DataStatus.loading ||
                        state.assetsStatus == DataStatus.initial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2.5,
                        ),
                      );
                    }

                    // Handle Asset Failure State
                    if (state.assetsStatus == DataStatus.failure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              "No internet connection",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Please check your connection",
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  context.read<AssetsCubit>().fetchAssets(),
                              child: const Text("Retry",
                                  style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      );
                    }

                    // Handle Asset Success State (with potentially empty list)
                    if (state.assetsStatus == DataStatus.success &&
                        state.displayedAssets.isEmpty) {
                      // Check if the master list had items to differentiate no results vs initial empty
                      bool wasMasterListPopulated = state.allAssets.isNotEmpty;
                      return Center(
                        child: Text(
                          wasMasterListPopulated
                              ? 'No assets found matching your search.'
                              : 'No assets available.\nPull down to refresh.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      );
                    }

                    // Display the assets list
                    return _buildAssetsList(context, state.displayedAssets);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search assets...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon:
            Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[850],
      ),
      onChanged: (query) => context.read<AssetsCubit>().searchAssets(query),
    );
  }

  Widget _buildAssetsList(BuildContext context, List<Assets> displayedAssets) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.grey[850],
      onRefresh: () async {
        context.read<AssetsCubit>().fetchAssets();
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: displayedAssets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _buildAssetTile(context, displayedAssets[index]),
      ),
    );
  }

  Widget _buildAssetTile(BuildContext context, Assets asset) {
    final assetsCubit = context.read<AssetsCubit>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Check if sequence is already loading
          if (assetsCubit.state.sequenceStatus != DataStatus.loading) {
            // Show loading indicator immediately
            _showLoadingDialog(context);
            // Trigger the sequence fetch for THIS asset's ID
            assetsCubit.fetchSequenceAccountNames(asset.accountID);
          } else {
            print("Sequence fetch already in progress.");
          }
        },
        splashColor: Colors.blueGrey.withOpacity(0.2),
        highlightColor: Colors.blueGrey.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 45,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: asset.isActive
                      ? Colors.greenAccent[700]
                      : Colors.grey[600],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      asset.accountName.isNotEmpty
                          ? asset.accountName
                          : '(No Name)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateSimple(asset.accCreatedDate),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[800]?.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${asset.balance >= 0 ? '' : '-'}\$${asset.balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: asset.balance >= 0
                        ? Colors.greenAccent[400]
                        : Colors.redAccent[200],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Dialogs and Formatters ---

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                // Use const here
                CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 3,
                ),
                SizedBox(width: 20),
                Text(
                  "Loading Sequence...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSequenceNamesDialog(BuildContext context, List<String> names) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          title: const Text(
            'Account Sequence',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shrinkWrap: true,
              itemCount: names.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    '${index + 1}. ${names[index]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: names[index] == 'Error Loading Name'
                            ? Colors.redAccent[100]
                            : Colors.grey[300],
                        fontSize: 15),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[700],
                height: 1,
                indent: 10,
                endIndent: 10,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 15),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blueGrey[700]!))),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.blueGrey[200]),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDateSimple(DateTime date) {
    if (date.year == 1 && date.month == 1 && date.day == 1) {
      return 'Date N/A';
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
