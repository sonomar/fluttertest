import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import './scan_view_receive.dart';
import './scan_view_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanViewSuccess extends StatefulWidget {
  const ScanViewSuccess({super.key, required this.qrcode});
  final String qrcode;

  @override
  State<ScanViewSuccess> createState() => _ScanViewSuccessState();
}

class _ScanViewSuccessState extends State<ScanViewSuccess>
    with SingleTickerProviderStateMixin {
  bool _clicked = false;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  final Tween<double> _opacityTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      _clicked = false;
    });
    final qrcode = widget.qrcode;
    final navigator = Navigator.of(context);

    SharedPreferences.getInstance().then((prefValue) => {
          if (widget.qrcode.contains('item-test'))
            {
              prefValue.setBool(qrcode, true),
              Future.delayed(const Duration(seconds: 3)).then((value) => {
                    _controller.forward(),
                    Future.delayed(const Duration(seconds: 2)).then((value) => {
                          if (_clicked == false)
                            {
                              navigator.pushReplacement(MaterialPageRoute(
                                  builder: (context) =>
                                      ScanViewReceive(qrcode: qrcode)))
                            }
                        }),
                  }),
            }
          else
            {
              {
                navigator.pushReplacement(MaterialPageRoute(
                    builder: (context) => const ScanViewError())),
              }
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
                    child: AnimatedOpacity(
                        opacity: _opacityTween.evaluate(_controller),
                        duration: Duration(seconds: 2),
                        child: Lottie.asset('assets/lottie/success2.json'))))));
  }
}
