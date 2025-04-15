import 'package:erp/Core/Helper/active_modules.dart';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/repos/activemodules/active_modules_repo.dart';
import 'package:erp/features/auth/logic/Auth/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'login_page.dart';
import 'home_screen.dart';
// Import the file where your simple ActiveModules is defined

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ... (AnimationController, animation, flags, repository instance remain the same) ...
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _animationCompleted = false;
  bool _authChecked = false;
  bool _isLoadingData = false;

  final CompanyRepository _companyRepository = CompanyRepository();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward().then((_) {
        if (mounted) {
          setState(() {
            _animationCompleted = true;
          });
          _checkNavigation();
        }
      });
      _initAuthCheck();
    });
  }

  Future<void> _initAuthCheck() async {
    if (mounted) {
      await context.read<AuthCubit>().checkAuthStatus();
      if (mounted) {
        setState(() {
          _authChecked = true;
        });
        _checkNavigation();
      }
    }
  }

  Future<bool> _authenticateUser() async {
    final auth = LocalAuthentication();
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return true;
      return await auth.authenticate(
          localizedReason: 'Please authenticate',
          options: const AuthenticationOptions(
              biometricOnly: true, stickyAuth: true));
    } catch (e) {
      print('Biometric error: $e');
      return true;
    }
  }

  // Updated method using your ActiveModules structure
  Future<void> _fetchDataAndUpdateStateAndNavigate() async {
    if (!mounted) return;
    setState(() {
      _isLoadingData = true;
    });

    try {
      print("Fetching current company data...");
      final companyData = await _companyRepository.getCurrentCompany();
      print("Successfully fetched company data: ${companyData.companyName}");

      // --- Update the static ActiveModules list ---

      // 1. Reset the list to all zeros (inactive) before applying new states
      print("Resetting ActiveModules list to all zeros.");
      for (int i = 0; i < ActiveModules.activeModules.length; i++) {
        ActiveModules.activeModules[i] = 0;
      }
      print("ActiveModules after reset: ${ActiveModules.activeModules}");

      // 2. Process fetched modules and update the list
      print("Processing fetched modules...");
      for (var module in companyData.companyModules) {
        // *** Assumption: moduleId 1 maps to index 0, 2 to 1, ..., 10 to 9 ***
        int index = module.moduleId - 1;

        // Check if the calculated index is valid for the list
        if (index >= 0 && index < ActiveModules.activeModules.length) {
          ActiveModules.activeModules[index] = module.isActive ? 1 : 0;
          print(
              " -> Module ID: ${module.moduleId} maps to Index: $index. Setting state to: ${ActiveModules.activeModules[index]} (isActive: ${module.isActive})");
        } else {
          print(
              " -> Warning: Module ID ${module.moduleId} is outside the expected range (1-10) and cannot be stored in the list. Ignoring.");
        }
      }
      print(
          "Final ActiveModules state after update: ${ActiveModules.activeModules}");
      // -------------------------------------------

      // --- Navigate to HomeScreen (without arguments) ---
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
      // -------------------------------------------------
    } catch (e) {
      print("Error fetching company data or updating state: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load configuration: ${e.toString()}',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red),
        );
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          // Reset list on failure before going to login
          print("Resetting ActiveModules list due to error.");
          for (int i = 0; i < ActiveModules.activeModules.length; i++) {
            ActiveModules.activeModules[i] = 0;
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginPage()));
        }
      }
    } finally {
      if (mounted) {
        await Future.delayed(Duration(milliseconds: 100));
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
        }
      }
    }
  }

  Future<void> _checkNavigation() async {
    print(
        "Checking navigation: AnimDone=$_animationCompleted, AuthChecked=$_authChecked, Loading=$_isLoadingData, Mounted=$mounted");
    if (_animationCompleted && _authChecked && !_isLoadingData && mounted) {
      final authState = context.read<AuthCubit>().state;
      print("Auth State: $authState");
      if (authState is AuthAuthenticated) {
        final token = await TokenStorage.getToken();
        print('Token retrieved: ${token != null ? "Exists" : "NULL"}');
        if (token != null) {
          bool isBiometricAuthenticated = await _authenticateUser();
          if (isBiometricAuthenticated && mounted) {
            await _fetchDataAndUpdateStateAndNavigate();
          } else if (mounted) {
            print("Biometric authentication failed or cancelled.");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => LoginPage()));
          }
        } else {
          print("Token is null, navigating to Login.");
          // Reset list if token missing
          print("Resetting ActiveModules list because token is null.");
          for (int i = 0; i < ActiveModules.activeModules.length; i++) {
            ActiveModules.activeModules[i] = 0;
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginPage()));
        }
      } else {
        print("AuthCubit state is not Authenticated, navigating to Login.");
        // Reset list if not authenticated
        print(
            "Resetting ActiveModules list because user is not authenticated.");
        for (int i = 0; i < ActiveModules.activeModules.length; i++) {
          ActiveModules.activeModules[i] = 0;
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method remains the same, showing the loading indicator) ...
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.business, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text("ERP App",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Ready to manage your business!",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              if (_isLoadingData) ...[
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                const SizedBox(height: 10),
                const Text("Loading configuration...",
                    style: TextStyle(color: Colors.white70)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// Make sure the simple ActiveModules class is defined and imported correctly
// Example: place this in lib/core/config/active_modules.dart
// class ActiveModules {
//   static List activeModules = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
// }
