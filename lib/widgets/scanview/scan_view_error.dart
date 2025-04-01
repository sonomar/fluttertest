import 'package:flutter/material.dart';
import '../../scan_screen.dart';
import 'package:lottie/lottie.dart';

class ScanViewError extends StatefulWidget {
  const ScanViewError({super.key});

  @override
  State<ScanViewError> createState() => _ScanViewErrorState();
}

class _ScanViewErrorState extends State<ScanViewError> {
  bool _clicked = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _clicked = false;
    });
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 3)).then((value) => {
          if (_clicked == false)
            {
              navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => ScanScreen())),
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            final navigator = Navigator.of(context);
            setState(() {
              _clicked = true;
            });
            navigator.pushReplacement(
                MaterialPageRoute(builder: (context) => ScanScreen()));
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo here
                Image.asset(
                  'assets/images/deins_logo.png',
                  height: 200,
                  width: 200,
                ),
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      'Incorrect QR Code Scanned!',
                      style: TextStyle(color: Colors.white),
                    )),
                SizedBox(
                    height: 40,
                    width: 40,
                    child: Lottie.asset('assets/lottie/pinkspin1.json')),
              ],
            ),
          ),
        ));
  }
}
