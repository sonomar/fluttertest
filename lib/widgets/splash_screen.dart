import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';
import '../models/asset_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Safely trigger the initialization after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// This function now has one job: run all startup tasks.
  /// Navigation is now handled by the router in main.dart.
  Future<void> _initializeApp() async {
    final authProvider = context.read<AppAuthProvider>();
    final assetProvider = context.read<AssetProvider>();

    // Run all independent startup tasks in parallel for efficiency.
    await Future.wait([
      authProvider.checkCurrentUser(),
      assetProvider.loadInitialAssets(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // The UI remains the same.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/deins_logo.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 40,
              width: 40,
              child: Lottie.asset('assets/lottie/pinkspin1.json'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
