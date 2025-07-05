import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ScanViewReceive extends StatefulWidget {
  const ScanViewReceive({super.key, required this.qrcode, this.userData});
  final String qrcode;
  final dynamic userData;

  @override
  State<ScanViewReceive> createState() => _ScanViewReceiveState();
}

class _ScanViewReceiveState extends State<ScanViewReceive>
    with SingleTickerProviderStateMixin {
  bool _clicked = false;
  String _item = 'assets/images/car1.png';

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..forward();
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset(0, -4.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final qrcode = widget.qrcode;
    final navigator = Navigator.of(context);
    setState(() {
      _clicked = false;
    });
    super.initState();
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
                builder: (context) => MyHomePage(
                    title: "Kloppocar Home",
                    qrcode: qrcode,
                    userData: widget.userData)));
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                      width: 300,
                      alignment: Alignment.center,
                      child: Image.asset(
                        _item,
                        fit: BoxFit.fill,
                      )),
                )
              ],
            ),
          ),
        ));
  }
}
