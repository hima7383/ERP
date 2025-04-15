// lib/features/auth/logic/splash_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<void> {
  SplashCubit() : super(null);

  void startTimer() async {
    await Future.delayed(Duration(seconds: 2));
    emit(null); // Notify to navigate
  }
}
