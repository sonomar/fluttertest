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
      final navigator = Navigator.of(context);
      final prefValue = await SharedPreferences.getInstance();
      await Future.delayed(const Duration(seconds: 3));
      // ignore: use_build_context_synchronously
      Provider.of<AppAuthProvider>(context, listen: false).checkCurrentUser();
      if ((prefValue.containsKey('jwtCode'))) {
        // ignore: use_build_context_synchronously
        final userModel = Provider.of<UserModel>(context, listen: false);
        try {
          await userModel.loadUser();
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
          print('Error loading user: $e');
          navigator.pushReplacement(
            MaterialPageRoute(
                builder: (context) => const LoginPage(userData: {})),
          );
        }
      } else {
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
