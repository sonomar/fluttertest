import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/asset_provider.dart';
import '../models/app_auth_provider.dart';
import '../models/user_model.dart';
import '../main.dart'; // Using the name from your example
import '../screens/auth_loading_screen.dart'; // Fallback for non-auth users

// Converted to a StatefulWidget to handle the initialization logic.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // --- CORRECTED ---
    // We use addPostFrameCallback to ensure that our initialization logic
    // runs *after* the first frame has been built. This completely avoids the
    // "setState() or markNeedsBuild() called during build" error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// This function runs all necessary startup tasks and then navigates.
  Future<void> _initializeApp() async {
    try {
      // Get provider instances using context.read.
      final assetProvider = context.read<AssetProvider>();
      final authProvider = context.read<AppAuthProvider>();

      // Use Future.wait to run independent startup tasks in parallel.
      await Future.wait([
        assetProvider.loadInitialAssets(), // Pre-loads the 3D assets.
        authProvider.checkCurrentUser(), // Checks for a logged-in session.
      ]);
    } catch (e) {
      debugPrint("Error during app initialization: $e");
    }

    // After all initialization is complete, check the results before navigating.
    if (mounted) {
      // We read the providers again to get their final status.
      final authProvider = context.read<AppAuthProvider>();
      final assetProvider = context.read<AssetProvider>();

      // We check if the user is authenticated AND if the essential asset loaded successfully.
      if (authProvider.status == AuthStatus.authenticated &&
          assetProvider.homeScreenGltfDataUrl != null) {
        // --- AUTHENTICATED & READY FLOW ---
        final userProvider = context.read<UserModel>();
        await userProvider.loadUser();

        // Final check to ensure we got the user data before navigating.
        if (mounted && userProvider.currentUser != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                title: "Kloppocar Home",
                qrcode: 'error',
                userData: userProvider.currentUser!,
              ),
            ),
          );
        } else {
          // Fallback if user data fails to load despite being authenticated.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthLoadingScreen()),
          );
        }
      } else {
        // --- FAILURE FLOW ---
        // If EITHER auth failed OR the essential asset failed to load,
        // navigate to a safe fallback screen.
        debugPrint(
            'Startup check failed. AuthStatus: ${authProvider.status}, AssetReady: ${assetProvider.homeScreenGltfDataUrl != null}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthLoadingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your existing splash screen UI is preserved perfectly.
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
