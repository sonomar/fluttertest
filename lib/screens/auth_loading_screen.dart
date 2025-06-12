import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _triggerLoadUserAndPermissions();
  }

  Future<void> _triggerLoadUserAndPermissions() async {
    await _requestInitialPermissions();
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

  /// Requests necessary permissions when the app starts.
  Future<void> _requestInitialPermissions() async {
    print('AuthLoadingScreen: Requesting initial permissions...');

    // Request Camera Permission
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      // Corrected: Use isDenied to cover 'notDetermined' and 'denied'
      print('Camera permission not determined or denied. Requesting...');
      await Permission.camera
          .request(); // This shows the iOS pop-up if not granted
    } else {
      print('Camera permission status: $cameraStatus');
    }

    // Request Location When In Use Permission
    var locationStatus = await Permission.locationWhenInUse.status;
    if (locationStatus.isDenied) {
      // Corrected: Use isDenied
      print('Location permission not determined or denied. Requesting...');
      await Permission.locationWhenInUse
          .request(); // This shows the iOS pop-up if not granted
    } else {
      print('Location permission status: $locationStatus');
    }

    // You can add more permissions here as needed, e.g.:
    // var photosStatus = await Permission.photos.status;
    // if (photosStatus.isDenied) { // Corrected: Use isDenied
    //   print('Photos permission not determined or denied. Requesting...');
    //   await Permission.photos.request();
    // } else {
    //   print('Photos permission status: $photosStatus');
    // }

    // If a permission is permanently denied, you might want to show a dialog
    // guiding the user to app settings. This is typically done when the user
    // tries to use a feature that requires the denied permission.
    if (cameraStatus.isPermanentlyDenied) {
      // Example of handling permanently denied permission
      print('Camera permission permanently denied. Guide user to settings.');
      // You could show a dialog here or a SnackBar
      // if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "If you wish to modify camera features, please enable in account settings."),
        ),
      );
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
