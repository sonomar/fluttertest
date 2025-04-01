import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'widgets/scanview/scan_view_loading.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 330.0;

    final MobileScannerController scanController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    // Future<void> collectedDialog(code) async {
    //   final prefs = await SharedPreferences.getInstance();

    //   return showDialog<void>(
    //     context: context,
    //     barrierDismissible: true, // user must tap button!
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('You got a Collectible!'),
    //         content: const SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Text('You can see it on the Collection page.'),
    //               Text('Scan other codes for more!'),
    //             ],
    //           ),
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             child: const Text('OK'),
    //             onPressed: () {
    //               prefs.setBool(code, true);
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => MyHomePage(
    //                         title: "Kloppocar Home",
    //                         qrcode:
    //                             code) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
    //                     ),
    //               );
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    // Future<void> rejectedDialog() async {
    //   return showDialog<void>(
    //     context: context,
    //     barrierDismissible: true, // user must tap button!
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Incorrect Code'),
    //         content: const SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Text('The code you scanned is not an authorized DEINS code'),
    //               Text('Scan authorized codes to collect!'),
    //             ],
    //           ),
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             child: const Text('OK'),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Scan Collectible"),
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            fontFamily: 'ChakraPetch',
          ),
        ),
        body: SizedBox(
            height: 400,
            child: MobileScanner(
                overlayBuilder: (context, constraints) => Align(
                      alignment: Alignment.center,
                      child: CustomPaint(
                        foregroundPainter: BorderPainter(),
                        child: SizedBox(
                          width: scanArea + 20,
                          height: scanArea + 20,
                        ),
                      ),
                    ),
                controller: scanController,
                onDetect: (barcode) {
                  final String code = barcode.barcodes.first.rawValue ?? '';

                  scanController.dispose();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScanViewLoading(
                            qrcode:
                                code) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                        ),
                  );
                })));
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0;
    const radius = 20.0;
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xffd622ca)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
