// import 'dart:async';
// import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../models/app_auth_provider.dart';
// import '../main.dart';
// import '../widgets/openCards/login_page.dart';
import 'package:lottie/lottie.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
