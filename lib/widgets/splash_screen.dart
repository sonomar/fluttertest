import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../helpers/localization_helper.dart';
import '../models/app_localizations.dart';
import '../models/app_auth_provider.dart';
import '../models/asset_provider.dart';
import '../models/user_model.dart';
import '../main.dart';
import './openCards/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// MODIFIED: This function now handles the case where user data fails to load for an authenticated user.
  Future<void> _initializeApp() async {
    try {
      await AppLocalizations.of(context)!.load();
      await _requestInitialPermissions();

      final authProvider = context.read<AppAuthProvider>();
      final assetProvider = context.read<AssetProvider>();
      final userProvider = context.read<UserModel>();

      // Check for a valid session first.
      await authProvider.checkCurrentUser();
      if (!mounted) return;

      if (authProvider.status == AuthStatus.authenticated) {
        // --- AUTHENTICATED FLOW ---
        // If authenticated, now try to load the essential user data.
        await Future.wait([
          userProvider.loadUser(),
          assetProvider.loadInitialAssets(),
        ]);

        if (!mounted) return;

        // CRITICAL FIX: After attempting to load, check if we actually got user data.
        if (userProvider.currentUser != null) {
          // If user data loaded successfully, proceed to the main app.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                title: translate("code_proc_success_hometitle", context),
                qrcode: 'login_success',
                userData: userProvider.currentUser!,
              ),
            ),
          );
        } else {
          // If user data failed to load despite a valid token, it's a critical error.
          // The session is invalid or corrupt. Force a sign-out and go to login.
          print(
              "SplashScreen: Valid session but failed to load user data. Forcing sign-out.");
          await authProvider.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        }
      } else {
        // --- UNAUTHENTICATED FLOW ---
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      debugPrint("A critical error occurred during initialization: $e");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  Future<void> _requestInitialPermissions() async {
    await Permission.camera.request();
    await Permission.locationWhenInUse.request();
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for push notifications.');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User denied permission for push notifications.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      print('User has not yet chosen notification permissions.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission for push notifications.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
