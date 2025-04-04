import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import './scan_view_receive.dart';

class ScanViewSuccess extends StatefulWidget {
  const ScanViewSuccess({super.key, required this.qrcode});
  final String qrcode;

  @override
  State<ScanViewSuccess> createState() => _ScanViewSuccessState();
}

class _ScanViewSuccessState extends State<ScanViewSuccess>
    with SingleTickerProviderStateMixin {
  bool _clicked = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _clicked = false;
    });
    final qrcode = widget.qrcode;
    final navigator = Navigator.of(context);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
    Future.delayed(const Duration(seconds: 4)).then((value) => {
          if (_clicked == false)
            {
              navigator.pushReplacement(MaterialPageRoute(
                  builder: (context) => ScanViewReceive(qrcode: qrcode))),
            }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  builder: (context) => ScanViewReceive(qrcode: qrcode)));
            },
            child: Center(
                child: Container(
                    alignment: Alignment.center,
                    width: 300,
                    child: Lottie.asset('assets/lottie/success2.json')))));
  }
}
