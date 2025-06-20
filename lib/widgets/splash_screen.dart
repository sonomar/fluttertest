import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/app_auth_provider.dart';
import '../models/asset_provider.dart';
import '../models/user_model.dart';
import '../main.dart'; // For MyHomePage
import './openCards/login_page.dart'; // For LoginPage

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

  /// This function is the single command center for app startup.
  Future<void> _initializeApp() async {
    try {
      // It's good practice to request permissions early.
      await _requestInitialPermissions();

      // Get all necessary provider instances.
      final authProvider = context.read<AppAuthProvider>();
      final assetProvider = context.read<AssetProvider>();
      final userProvider = context.read<UserModel>();

      // 1. Check for an existing session.
      await authProvider.checkCurrentUser();

      // If the widget is no longer in the tree after an async gap, abort.
      if (!mounted) return;

      // 2. Based on the authentication status, decide the next step.
      if (authProvider.status == AuthStatus.authenticated) {
        // --- AUTHENTICATED FLOW ---
        // Load user data and pre-load assets in parallel for efficiency.
        await Future.wait([
          userProvider.loadUser(),
          assetProvider.loadInitialAssets(),
        ]);

        if (!mounted) return;

        // Check if both user data and essential assets loaded successfully.
        if (userProvider.currentUser != null && assetProvider.isReady) {
          // Navigate to the main app screen.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                title: "Kloppocar Home",
                qrcode: 'error', // As per your example
                userData: userProvider.currentUser!,
              ),
            ),
          );
        } else {
          // If something failed (e.g., user data fetch failed), it's safest
          // to sign the user out to get a clean state and go to the login page.
          await authProvider.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        }
      } else {
        // --- UNAUTHENTICATED FLOW ---
        // If the user is not authenticated, navigate directly to the login page.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      debugPrint("A critical error occurred during initialization: $e");
      // On any unhandled exception, navigate to the login page as a safe fallback.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  /// Requests necessary permissions when the app starts.
  Future<void> _requestInitialPermissions() async {
    await Permission.camera.request();
    await Permission.locationWhenInUse.request();
  }

  @override
  Widget build(BuildContext context) {
    // This UI is shown while the _initializeApp function is running.
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
