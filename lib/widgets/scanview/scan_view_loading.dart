import 'package:flutter/material.dart';
import 'package:kloppocar_app/screens/subscreens/collectibles/collectible.dart';
import './scan_view_success.dart';
import './scan_view_error.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanViewLoading extends StatefulWidget {
  const ScanViewLoading(
      {super.key, required this.qrcode, required this.collectibles});
  final String qrcode;
  final List collectibles;

  @override
  State<ScanViewLoading> createState() => _ScanViewLoadingState();
}

class _ScanViewLoadingState extends State<ScanViewLoading> {
  bool _clicked = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _clicked = false;
    });
    final qrcode = widget.qrcode;
    final navigator = Navigator.of(context);
    SharedPreferences.getInstance().then((prefValue) =>
        Future.delayed(const Duration(seconds: 3)).then((value) => {
              if (_clicked == false)
                {
                  if (widget.qrcode.contains('item-test'))
                    {
                      prefValue.setBool(qrcode, true),
                      navigator.pushReplacement(MaterialPageRoute(
                          builder: (context) => ScanViewSuccess(
                                qrcode: qrcode,
                                collectibles: widget.collectibles,
                              ))),
                    }
                  else
                    {
                      {
                        navigator.pushReplacement(MaterialPageRoute(
                            builder: (context) => const ScanViewError())),
                      }
                    }
                }
            }));
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
            if (widget.qrcode.contains('item-test')) {
              navigator.pushReplacement(MaterialPageRoute(
                  builder: (context) => ScanViewSuccess(
                        qrcode: qrcode,
                        collectibles: widget.collectibles,
                      )));
            } else {
              navigator.pushReplacement(MaterialPageRoute(
                  builder: (context) => const ScanViewError()));
            }
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
                      'Scanning...',
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
