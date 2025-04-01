import 'package:flutter/material.dart';
import './scan_view_success.dart';

class ScanViewReceive extends StatefulWidget {
  const ScanViewReceive({super.key, required this.qrcode});
  final String qrcode;

  @override
  State<ScanViewReceive> createState() => _ScanViewReceiveState();
}

class _ScanViewReceiveState extends State<ScanViewReceive> {
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
                  builder: (context) => ScanViewSuccess(qrcode: qrcode))),
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            final qrcode = widget.qrcode;
            final navigator = Navigator.of(context);
            setState(() {
              _clicked = true;
            });
            navigator.pushReplacement(MaterialPageRoute(
                builder: (context) => ScanViewSuccess(qrcode: qrcode)));
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
                    child: Text('Collectible Received!')),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
              ],
            ),
          ),
        ));
  }
}
