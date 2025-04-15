import 'package:erp/features/auth/data/entities/accounts/accounts.dart';
import 'package:erp/features/auth/data/repos/accounts/accounts_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart'; // Import Equatable if used in state
// --- State Definition ---

// Enums to represent the status of different operations
enum DataStatus { initial, loading, success, failure }

class AssetsState extends Equatable {
  // Status for fetching all assets
  final DataStatus assetsStatus;
  // Status for fetching sequence names
  final DataStatus sequenceStatus;

  // Data for all assets
  final List<Assets> allAssets;       // Master list
  final List<Assets> displayedAssets; // List shown in UI (potentially filtered)

  // Data for sequence names
  final List<String> sequenceNames;

  // Error message (can be shared or specific)
  final String? errorMessage;

  const AssetsState({
    this.assetsStatus = DataStatus.initial,
    this.sequenceStatus = DataStatus.initial,
    this.allAssets = const [],
    this.displayedAssets = const [],
    this.sequenceNames = const [],
    this.errorMessage,
  });

  // Helper method to create copies of the state with modifications
  AssetsState copyWith({
    DataStatus? assetsStatus,
    DataStatus? sequenceStatus,
    List<Assets>? allAssets,
    List<Assets>? displayedAssets,
    List<String>? sequenceNames,
    String? errorMessage,
    bool clearErrorMessage = false, // Flag to explicitly clear error
  }) {
    return AssetsState(
      assetsStatus: assetsStatus ?? this.assetsStatus,
      sequenceStatus: sequenceStatus ?? this.sequenceStatus,
      allAssets: allAssets ?? this.allAssets,
      displayedAssets: displayedAssets ?? this.displayedAssets,
      sequenceNames: sequenceNames ?? this.sequenceNames,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        assetsStatus,
        sequenceStatus,
        allAssets,
        displayedAssets,
        sequenceNames,
        errorMessage,
      ];
}


// --- Cubit Definition ---

class AssetsCubit extends Cubit<AssetsState> {
  final AccountsRepository repository;

  AssetsCubit(this.repository) : super(const AssetsState()); // Initial state

  // --- Existing Functionality (Adapted for AssetsState) ---

  // Fetch ALL secondary accounts (assets)
  Future<void> fetchAssets() async {
    // Emit loading state specifically for assets
    emit(state.copyWith(assetsStatus: DataStatus.loading, clearErrorMessage: true));
    try {
      final List<Assets> fetchedAssets = await repository.fetchassests();

      // Emit success state with the fetched assets
      emit(state.copyWith(
        assetsStatus: DataStatus.success,
        allAssets: fetchedAssets,
        displayedAssets: fetchedAssets, // Initially display all fetched assets
      ));
    } catch (e) {
      print('Error fetching assets: $e');
      // Emit failure state specifically for assets
      emit(state.copyWith(
        assetsStatus: DataStatus.failure,
        errorMessage: 'Failed to load assets: ${e.toString()}',
        allAssets: [], // Clear lists on failure
        displayedAssets: [],
      ));
    }
  }

  // Search assets by name (Filters the existing 'allAssets' list)
  void searchAssets(String query) {
    // Don't change status, just filter data already loaded
    if (state.assetsStatus != DataStatus.success) {
       return; // Can't search if assets haven't been loaded successfully
    }

    if (query.isEmpty) {
      // Reset to show all loaded assets
      emit(state.copyWith(displayedAssets: state.allAssets));
    } else {
      final filteredAssets = state.allAssets
          .where((asset) =>
              asset.accountName.toLowerCase().contains(query.toLowerCase()))
          .toList();
      // Emit state with the filtered list for display
      emit(state.copyWith(displayedAssets: filteredAssets));
    }
  }

  // --- New Functionality ---

  // Fetches sequence, gets types, fetches accounts, and updates sequenceNames
  Future<void> fetchSequenceAccountNames(int initialId) async {
    // Emit loading state specifically for the sequence operation
    emit(state.copyWith(sequenceStatus: DataStatus.loading, clearErrorMessage: true));
    try {
      // 1. Fetch the sequence of IDs (assuming repository returns List<int>)
      final List<int> accountIds = await repository.fetchSequence(initialId);

      final List<String> fetchedNames = [];

      // 2. Iterate through IDs
      for (int id in accountIds) {
        String name = 'Unknown Account'; // Default name
        try {
          // 3. Get account type (assuming repository returns "Primary" or "Secondary")
          final String accountType = await repository.getAccountTypeById(id);

          // 4. Fetch account details based on type
          if (accountType == "Primary") { // Check for "Primary"
            // Assuming fetchMainAccountById exists and returns an object with accountName
            final account = await repository.fetchMainAccountById(id);
            name = account.accountName;
          } else if (accountType == "Secondary") { // Check for "Secondary"
            // Assuming fetchAssetById exists and returns an Assets object
            final asset = await repository.fetchAssetById(id);
            name = asset.accountName;
          } else {
            print("Unknown account type string '$accountType' received for ID $id");
            name = 'Invalid Type Received';
          }
        } catch (e) {
          // Handle error fetching details for a *single* ID
          print('Error processing account ID $id: $e');
          name = 'Error Loading Name'; // Placeholder on error for this specific ID
        }
        fetchedNames.add(name);
      }

      // 5. Emit success state with the fetched names
      emit(state.copyWith(
        sequenceStatus: DataStatus.success,
        sequenceNames: fetchedNames,
      ));

    } catch (e) {
      // Handle error fetching the initial sequence or other general errors
      print('Error fetching account names sequence: $e');
      // Emit failure state specifically for the sequence operation
      emit(state.copyWith(
        sequenceStatus: DataStatus.failure,
        errorMessage: 'Failed to load account sequence: ${e.toString()}',
        sequenceNames: [], // Clear names on failure
      ));
    }
  }
}