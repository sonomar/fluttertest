import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/asset_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the AssetProvider to get live updates on the pre-loading status.
    final assetProvider = context.watch<AssetProvider>();

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
            const SizedBox(
              height: 40,
            ),
            SizedBox(
                height: 40,
                width: 40,
                child: Lottie.asset('assets/lottie/pinkspin1.json')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
