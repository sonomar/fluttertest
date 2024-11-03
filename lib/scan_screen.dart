import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        child: MobileScanner(onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            // ignore: avoid_print
            print(barcode.rawValue ?? "No Data found in QR");
          }
        }));
  }
}
