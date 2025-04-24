// connectivity_cubit.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  ConnectivityCubit() : super(true) {
    _init();
  }

  Future<void> _init() async {
    await checkConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) => checkConnectivity());
  }

  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    emit(result != ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}