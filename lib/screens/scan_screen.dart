import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/distribution_model.dart'; // Import DistributionModel
import '../helpers/localization_helper.dart';
import '../widgets/scan/code_processing_screen.dart';
import '../models/mission_model.dart'; // FOR TESTING. REMOVE WITH TEST BUTTONS

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

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
    // Pre-load the user's redeemed codes to make the processing screen faster.
    Provider.of<DistributionModel>(context, listen: false)
        .loadUserRedeemedCodes(forceReload: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _codeTextController.dispose();
    super.dispose();
  }

  void _triggerCodeProcessing(String code) {
    if (code.isEmpty) return;
    _scanController.stop();

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) =>
            CodeProcessingScreen(code: code, userData: widget.userData),
      ),
    )
        .then((_) {
      if (mounted) {
        _scanController.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 330.0;

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
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: translate("scan_manual_text", context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _triggerCodeProcessing(
                    _codeTextController.text.toUpperCase()),
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
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Call the new debug function from the model
                  context.read<DistributionModel>().resetTestCode();
                  // Show a snackbar to confirm the action was triggered
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Attempting to reset test code...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor:
                      Colors.grey[700], // A different color for debug buttons
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset test code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Call the new debug function from the MissionModel
                  context.read<MissionModel>().resetTestMissionProgress();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text("Attempting to reset mission progress...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor:
                      Colors.blueGrey[700], // A different color for this button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset Mission Progress',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = 4.0;
    final radius = 20.0;
    final tRadius = 2 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final clippingRect0 = Rect.fromLTWH(0, 0, tRadius, tRadius);
    final clippingRect1 = Rect.fromLTWH(0, 0, tRadius, tRadius);
    final clippingRect2 =
        Rect.fromLTWH(size.width - tRadius, 0, tRadius, tRadius);
    final clippingRect3 =
        Rect.fromLTWH(0, size.height - tRadius, tRadius, tRadius);
    final clippingRect4 = Rect.fromLTWH(
        size.width - tRadius, size.height - tRadius, tRadius, tRadius);

    final path = Path()
      ..addRRect(rrect)
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3)
      ..addRect(clippingRect4);
    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
