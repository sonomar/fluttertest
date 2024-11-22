import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import './main.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Scan Collectible"),
        ),
        body: SizedBox(
            height: 400,
            child: MobileScanner(
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
