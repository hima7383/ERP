import 'package:erp/features/auth/data/entities/accounts/daily.dart';
import 'package:erp/features/auth/data/repos/accounts/daily.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JournalEntryCubit extends Cubit<JournalEntryState> {
  final JournalEntryRepository _repository;
  List<JournalEntry> _allEntries = []; // Store all entries for filtering

  JournalEntryCubit(this._repository) : super(JournalEntryInitial());

  void fetchJournalEntries() async {
    emit(JournalEntryLoading());
    try {
      _allEntries = await _repository.fetchJournalEntries();
      emit(JournalEntryLoaded(_allEntries));
    } catch (e) {
      emit(JournalEntryError(e.toString()));
    }
  }

  void searchJournalEntries(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all entries
      emit(JournalEntryLoaded(_allEntries));
    } else {
      // Filter entries based on the description
      final filteredEntries = _allEntries
          .where((entry) =>
              entry.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(JournalEntryLoaded(filteredEntries));
    }
  }
}

abstract class JournalEntryState {}

class JournalEntryInitial extends JournalEntryState {}

class JournalEntryLoading extends JournalEntryState {}

class JournalEntryLoaded extends JournalEntryState {
  final List<JournalEntry> entries;

  JournalEntryLoaded(this.entries);
}

class JournalEntryError extends JournalEntryState {
  final String message;

  JournalEntryError(this.message);
}
