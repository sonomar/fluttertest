import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import './main.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 330.0;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Scan Collectible"),
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
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.noDuplicates,
                ),
                onDetect: (barcode) {
                  final String code = barcode.barcodes.first.rawValue ?? '';
                  if (code.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyHomePage(
                              title: "Kloppocar Home",
                              qrcode:
                                  code) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                          ),
                    );
                  }
                  ;
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
