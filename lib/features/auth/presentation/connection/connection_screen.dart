// network_aware_app.dart
import 'package:erp/features/auth/logic/connecting/connect_cubit.dart';
import 'package:erp/features/auth/logic/stock/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkAwareApp extends StatelessWidget {
  final Widget child;

  const NetworkAwareApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, bool>(
      listener: (context, isConnected) {
        if (!isConnected) {
          // Optionally show a snackbar when connection is lost
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No internet connection"),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Retry all cubits when connection returns
          context.read<ProductCubit>().fetchProducts();
        }
      },
      child: Stack(
        children: [
          child,
          BlocBuilder<ConnectivityCubit, bool>(
            builder: (context, isConnected) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isConnected
                    ? const SizedBox.shrink()
                    : Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 16),
                              Text(
                                "Waiting for connection...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}