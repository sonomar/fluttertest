import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/app_auth_provider.dart';
import '../main.dart'; // For MyHomePage

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // As soon as this screen appears, we know we're authenticated.
    // Trigger the user profile load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserModel>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the UserModel to react when the profile data arrives.
    return Consumer<UserModel>(
      builder: (context, userModel, _) {
        // If we are actively loading the user, show a spinner.
        if (userModel.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // If loading is finished and we have a user, show the main app.
        if (userModel.currentUser != null) {
          return MyHomePage(
            title: "Kloppocar Home",
            qrcode: 'error',
            userData: userModel.currentUser!,
          );
        }

        // If loading finished but we still have NO user (e.g., an API error),
        // trigger a sign out. The router in main.dart will then automatically
        // show the LoginPage.
        if (userModel.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AppAuthProvider>().signOut();
          });
        }

        // In all other cases, show a loading indicator.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
