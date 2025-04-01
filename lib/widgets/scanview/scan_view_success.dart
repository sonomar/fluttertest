import 'package:flutter/material.dart';
import '../../main.dart';

class ScanViewSuccess extends StatefulWidget {
  const ScanViewSuccess({super.key, required this.qrcode});
  final String qrcode;

  @override
  State<ScanViewSuccess> createState() => _ScanViewSuccessState();
}

class _ScanViewSuccessState extends State<ScanViewSuccess> {
  bool _clicked = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _clicked = false;
    });
    final qrcode = widget.qrcode;
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 4)).then((value) => {
          if (_clicked == false)
            {
              navigator.pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      MyHomePage(title: "Kloppocar Home", qrcode: qrcode))),
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            setState(() {
              _clicked = true;
            });
            final qrcode = widget.qrcode;
            final navigator = Navigator.of(context);
            navigator.pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(title: "Kloppocar Home", qrcode: qrcode)));
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
                    child: Text('Success!')),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              ],
            ),
          ),
        ));
  }
}
