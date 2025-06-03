import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';
import '../models/user_model.dart';
import '../widgets/splash_screen.dart'; // Your existing SplashScreen widget
import '../main.dart'; // For MyHomePage (assuming main.dart still contains MyHomePage)
import '../widgets/openCards/login_page.dart'; // For LoginPage
import 'package:shared_preferences/shared_preferences.dart';

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // This initState is called only once when AuthLoadingScreen is first built.
    // It provides a stable context to trigger loadUser().
    _triggerLoadUser();
  }

  Future<void> _triggerLoadUser() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    print(
        'AuthLoadingScreen: _triggerLoadUser started from initState at ${DateTime.now()}');

    // Only proceed if user data isn't loaded and not already loading.
    if (userModel.currentUser == null && !userModel.isLoading) {
      // Handle prior errors if any
      if (userModel.errorMessage != null) {
        print(
            'AuthLoadingScreen: Prior UserModel error detected. Signing out.');
        await authProvider
            .signOut(); // This will change AuthStatus to unauthenticated
        userModel.clearUser();
        return;
      }

      print(
          'AuthLoadingScreen: Calling UserModel.loadUser() at ${DateTime.now()}');
      try {
        await userModel.loadUser(); // Await the completion of loadUser
      } catch (e) {
        // If loadUser throws an unhandled error, ensure state is clean
        print(
            'AuthLoadingScreen: Error during UserModel.loadUser: $e. Forcing sign out.');
        await authProvider.signOut();
        userModel.clearUser();
      }
    } else {
      print(
          'AuthLoadingScreen: UserModel already loaded or loading in initState. currentUser: ${userModel.currentUser != null ? "loaded" : "null"} isLoading: ${userModel.isLoading}');
    }

    // After loadUser (or if it was already loaded/loading), ensure this widget rebuilds
    // to reflect the final state. This is especially important if loadUser() was awaited
    // and its state changed.
    if (mounted) {
      setState(() {}); // Force rebuild of AuthLoadingScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    // This consumer rebuilds whenever UserModel changes (isLoading, currentUser, errorMessage)
    return Consumer<UserModel>(
      builder: (context, userModel, _) {
        print(
            'AuthLoadingScreen: Build method. isLoading=${userModel.isLoading}, currentUser=${userModel.currentUser != null ? "loaded" : "null"} at ${DateTime.now()}');

        // Show SplashScreen if data is currently loading.
        if (userModel.isLoading) {
          print(
              'AuthLoadingScreen: UserModel is loading. Showing SplashScreen.');
          return const SplashScreen();
        }

        // If user data is loaded, return MyHomePage.
        if (userModel.currentUser != null) {
          print(
              'AuthLoadingScreen: UserModel loaded. Returning MyHomePage at ${DateTime.now()}');
          final userId = userModel.currentUser['userId']?.toString();
          if (userId != null) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('userId', userId);
            });
          }
          return MyHomePage(
            title: 'Kloppocar App Home',
            qrcode: 'Scan a Collectible!',
            userData: userModel.currentUser,
          );
        }

        // Handle error state if loadUser failed or if inconsistent state.
        if (userModel.errorMessage != null) {
          print('AuthLoadingScreen: UserModel Error. Navigating to LoginPage.');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<AppAuthProvider>(context, listen: false).signOut();
            userModel.clearUser();
          });
          return const LoginPage(userData: {});
        }

        // Fallback: If somehow not loading, no user, no error (e.g., initial state).
        // This should theoretically not be reached if _triggerLoadUser runs correctly.
        print(
            'AuthLoadingScreen: Unexpected state (not loading, no user, no error). Defaulting to SplashScreen.');
        return const SplashScreen();
      },
    );
  }
}
