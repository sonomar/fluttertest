import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../main.dart';

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
                  builder: (context) =>
                      MyHomePage(title: "Kloppocar Home", qrcode: qrcode))),
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
                builder: (context) =>
                    MyHomePage(title: "Kloppocar Home", qrcode: qrcode)));
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    child: Container(
                      alignment: Alignment.center,
                      child: Stack(alignment: Alignment.center, children: [
                        SvgPicture.asset(
                          'assets/images/orbBurst.svg',
                          fit: BoxFit.cover,
                        ),
                        SvgPicture.asset(
                          'assets/images/starBurst.svg',
                          fit: BoxFit.cover,
                        ),
                      ]),
                    )),
                Image.asset('assets/images/check.png',
                    height: 100, width: 100, alignment: Alignment.center)
              ],
            ),
          ),
        ));
  }
}
