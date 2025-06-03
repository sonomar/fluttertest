import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/app_auth_provider.dart';
import '../main.dart';
import '../widgets/openCards/login_page.dart';
import 'package:lottie/lottie.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future<void> navigateToHomeOrLogin() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      final appAuthProvider =
          Provider.of<AppAuthProvider>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      await appAuthProvider.checkCurrentUser();
      final navigator = Navigator.of(context);
      if (appAuthProvider.status == AuthStatus.authenticated) {
        try {
          await userModel.loadUser();
          final SharedPreferences prefValue =
              await SharedPreferences.getInstance();
          final userData = userModel.currentUser;
          final userId = userModel.currentUser['userId'].toString();
          prefValue.setString('userId', userId);
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                title: 'Kloppocar App Home',
                qrcode: 'Scan a Collectible!',
                userData: userData, // Pass the loaded user data here
              ),
            ),
          );
        } catch (e) {
          // Handle error if user data loading fails
          print('Error loading user data after successful authentication: $e');
          await appAuthProvider.signOut();
          navigator.pushReplacement(
            MaterialPageRoute(
                builder: (context) => const LoginPage(userData: {})),
          );
        }
      } else {
        print('User is unauthenticated. Navigating to Login.');
        navigator.pushReplacement(
          MaterialPageRoute(
              builder: (context) => const LoginPage(userData: {})),
        );
      }
    }

    navigateToHomeOrLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo here
            Image.asset(
              'assets/images/deins_logo.png',
              height: 200,
              width: 200,
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
                height: 40,
                width: 40,
                child: Lottie.asset('assets/lottie/pinkspin1.json')),
          ],
        ),
      ),
    );
  }
}
