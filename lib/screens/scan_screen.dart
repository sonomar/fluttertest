import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/collectible_model.dart';
import '../helpers/localization_helper.dart';
import '../widgets/scan/code_processing_screen.dart'; // Import the new screen

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.userData});
  final dynamic userData;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final TextEditingController _codeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // It's still a good idea to ensure collectibles are loaded for context,
    // though the main processing will happen in the new screen.
    Provider.of<CollectibleModel>(context, listen: false).loadCollectibles();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _codeTextController.dispose();
    super.dispose();
  }

  // --- START OF NEW SIMPLIFIED LOGIC ---
  /// This function now just navigates to the processing screen.
  void _triggerCodeProcessing(String code) {
    if (code.isEmpty) return;

    // Stop the camera before navigating away.
    _scanController.stop();

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) =>
            CodeProcessingScreen(code: code, userData: widget.userData),
      ),
    )
        .then((_) {
      // When we return from the processing screen (e.g., on an error),
      // restart the camera for the next scan.
      if (mounted) {
        _scanController.start();
      }
    });
  }
  // --- END OF NEW SIMPLIFIED LOGIC ---

  @override
  Widget build(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 330.0;

    // The build method is now much simpler. It only shows the scanner UI.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        title: Text(translate("scan_sub_header", context)),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontFamily: 'ChakraPetch',
          fontWeight: FontWeight.w500,
        ),
      ),
      body: _buildScannerAndInput(scanArea),
    );
  }

  Widget _buildScannerAndInput(double scanArea) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            overlayBuilder: (context, constraints) => Align(
              alignment: Alignment.center,
              child: CustomPaint(
                foregroundPainter: BorderPainter(),
                child: SizedBox(width: scanArea, height: scanArea),
              ),
            ),
            controller: _scanController,
            onDetect: (barcode) {
              final String code = barcode.barcodes.first.rawValue ?? '';
              _triggerCodeProcessing(code);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _codeTextController,
                decoration: InputDecoration(
                  labelText: translate("scan_manual_text", context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    _triggerCodeProcessing(_codeTextController.text),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Color.fromARGB(202, 214, 34, 202),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  translate("scan_manual_submit_button_text", context),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for the QR scan area border.
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ... (implementation remains the same)
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
