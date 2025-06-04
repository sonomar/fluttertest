import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/collectible_model.dart'; // Ensure this path is correct
import '../models/user_model.dart';
import '../main.dart'; // Assuming MyHomePage is in main.dart
import '../helpers/get_random.dart'; // Import the new random mint generator

// Enum to manage the different states of the scan/code input process
enum ScanState {
  scanning, // Initial state: showing QR scanner and text input
  loading, // Showing loading animation
  success, // Showing success animation
  error, // Showing error message
  received, // Final state after success, before navigating home
}

// Helper classes to match the expected input structure of generateRandomMint
// as it expects objects with properties, not raw maps.
// These classes MUST be at the top-level of the file, outside of any other class or function.
class CollectibleWrapper {
  final String id;
  final int circulation;

  CollectibleWrapper(this.id, this.circulation);
}

class UserCollectibleWrapper {
  final String collectibleId;
  final int mint;

  UserCollectibleWrapper(this.collectibleId, this.mint);
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.userData});
  final dynamic userData;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  // Controller for the QR scanner
  final MobileScannerController _scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // Controller for the manual code input field
  final TextEditingController _codeTextController = TextEditingController();

  // Current state of the scanning/code input process
  ScanState _currentScanState = ScanState.scanning;

  // Store the code that was scanned or entered
  String _processedCode = '';

  // Animation controller for success Lottie animation
  late final AnimationController _successLottieController;
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    // Initialize the Lottie animation controller
    _successLottieController = AnimationController(
      duration:
          const Duration(seconds: 2), // Duration for the success animation
      vsync: this,
    );

    // Removed: _scanController.start();
    // The MobileScanner widget will handle starting the camera when it's built.

    // Load collectibles when the screen initializes
    Provider.of<CollectibleModel>(context, listen: false).loadCollectibles();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _scanController.stop();
    _scanController.dispose();
    _codeTextController.dispose();
    _successLottieController.dispose();
    super.dispose();
  }

  /// Determines if the provided code is valid based on a prefix.
  bool _isCodeValid(String code) {
    if (code.isEmpty) return false;
    // Split the code by hyphen and check the first part
    final List<String> splitCode = code.split('-');
    return splitCode.isNotEmpty && splitCode[0] == 'deinsqr';
  }

  bool _isTradeCode(String code) {
    final List<String> parts = code.split('-');
    return parts.length == 4 &&
        (parts[0] == 'deinsQr' || parts[0] == 'deinsqr') &&
        parts[1] == 'trade';
  }

  /// Handles the processing of a QR code or manually entered code.
  /// This method orchestrates the state changes and business logic.
  Future<void> _processCode(String code) async {
    if (!mounted) return; // Ensure widget is still in the tree

    // Stop the scanner immediately upon detection/input
    _scanController.stop();

    if (_isTradeCode(code)) {
      setState(() {
        _processedCode = code;
        _currentScanState = ScanState.loading;
      });
      await _processTrade(code);
    } else if (_isCodeValid(code)) {
      // Existing logic for non-trade codes
      setState(() {
        _processedCode = code;
        _currentScanState = ScanState.loading;
      });

      // Simulate network delay or processing time
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return; // Check again after delay

      final collectibleModel =
          Provider.of<CollectibleModel>(context, listen: false);
      final List collectionCollectibles =
          collectibleModel.collectionCollectibles;
      final List userCollectiblesRaw = collectibleModel
          .userCollectibles; // Get raw list of user collectibles

      // Convert raw userCollectibles (List<Map>) to a list of UserCollectibleWrapper
      final List<UserCollectibleWrapper> userCollectiblesWrapped =
          userCollectiblesRaw.map((ucMap) {
        return UserCollectibleWrapper(
          ucMap["collectibleId"].toString(),
          ucMap["mint"] is int
              ? ucMap["mint"] as int
              : int.tryParse(ucMap["mint"].toString()) ?? 0,
        );
      }).toList();

      try {
        final SharedPreferences prefValue =
            await SharedPreferences.getInstance();
        await prefValue.setBool(code, true); // Mark code as used

        final String? userId = prefValue.getString("userId");
        final String collectibleId = code.split('-').last;

        // Find the specific collectible object (Map) from collectionCollectibles
        final Map<String, dynamic>? foundCollectibleMap =
            collectionCollectibles.firstWhere(
          (c) => c["collectibleId"].toString() == collectibleId,
          orElse: () => null, // Return null if collectible is not found
        );

        if (foundCollectibleMap == null) {
          // If collectible not found in collection, treat as an error
          debugPrint(
              'Collectible with ID $collectibleId not found in collection.');
          setState(() {
            _currentScanState = ScanState.error;
          });
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: "Kloppocar Home",
              qrcode: 'error',
              userData: widget.userData,
            ),
          ));
          return; // Exit early
        }

        // Create CollectibleWrapper from the found map to pass to generateRandomMint
        final CollectibleWrapper wrappedCollectible = CollectibleWrapper(
          // Ensure 'id' (collectibleId) is always a String
          foundCollectibleMap["collectibleId"].toString(),
          foundCollectibleMap["circulation"] is int
              ? foundCollectibleMap["circulation"] as int
              : int.tryParse(foundCollectibleMap["circulation"].toString()) ??
                  0,
        );

        // Call generateRandomMint to get a new mint number
        final int? generatedMint = generateRandomMint(
          wrappedCollectible,
          userCollectiblesWrapped,
        );

        if (generatedMint == null) {
          // If generateRandomMint returns null, it means all mints are taken or an issue occurred
          debugPrint('No available mints for collectible ID $collectibleId.');
          setState(() {
            _currentScanState = ScanState.error;
          });
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: "Kloppocar Home",
              qrcode: 'error',
              userData: widget.userData,
            ),
          ));
          return; // Exit early
        }

        final String mint = generatedMint.toString();
        print('heeeeres the fun!: $userId, $collectibleId, $mint');
        // Add user collectible with the newly generated mint
        await collectibleModel.addUserCollectible(userId, collectibleId, mint);

        // The updateCollectible call is removed as requested, as circulation is now handled by mint generation.

        setState(() {
          _currentScanState = ScanState.success; // Show success animation
        });

        // Play success Lottie animation
        _successLottieController.forward();

        // Wait for animation to complete, then transition to final received state
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        setState(() {
          _currentScanState = ScanState.received; // Indicate final state
        });

        // After a short delay, navigate to the home page
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: "Kloppocar Home",
            qrcode: code, // Pass the successfully processed code
            userData: widget.userData,
          ),
        ));
      } catch (e) {
        // Handle any errors during data processing
        debugPrint('Error processing collectible: $e');
        setState(() {
          _currentScanState = ScanState.error; // Show error message
        });
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: "Kloppocar Home",
            qrcode: 'error',
            userData: widget.userData,
          ),
        ));
      }
    } else {
      setState(() {
        _currentScanState = ScanState.error; // Show error message
      });
      // After a short delay, navigate to the home page
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: "Kloppocar Home",
          qrcode: 'error',
          userData: widget.userData,
        ),
      ));
    }
  }

  Future<void> _processTrade(String tradeCode) async {
    if (!mounted) return;

    final List<String> parts = tradeCode.split('-');
    // String qrType = parts[0]; // "deinsQr"
    // String tradeMarker = parts[1]; // "trade"
    String giverUserId = parts[2];
    String userCollectibleIdToTrade = parts[3];

    final collectibleModel =
        Provider.of<CollectibleModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    final String? receiverUserId = userModel.currentUser?['userId']?.toString();

    if (receiverUserId == null) {
      _handleTradeError("Could not identify current user to receive trade.");
      return;
    }

    if (receiverUserId == giverUserId) {
      _handleTradeError("Cannot trade a collectible to yourself.");
      return;
    }

    // Simulate fetching the specific UserCollectible (in a real app, this might be an API call if not already loaded)
    // For now, we try to find it in the loaded list by the CollectibleModel.
    // This part is tricky as the receiver's app doesn't have the giver's UserCollectibles loaded.
    // The API for updateUserCollectibleStatus will need to fetch it by userCollectibleIdToTrade.
    // The client-side check for `active == 0` needs the backend to enforce it or provide the data.
    // For now, let's assume the backend handles checking the `active` status before updating owner.

    // The CollectibleModel's `getLocalUserCollectibleById` would only find it if the receiver somehow had it.
    // The critical step is the API call. The `active` status check should ideally happen server-side during the update.
    // If the server successfully updates ownerId only if active=false, that's the best enforcement.

    // 2c. Update UserCollectible: new owner, active=true, previousOwnerId
    // The `updateUserCollectibleStatus` method will call the API.
    // The API should check if the item with `userCollectibleIdToTrade` has `active: false` AND `ownerId: giverUserId`.
    bool tradeSuccess = await collectibleModel.updateUserCollectibleStatus(
        userCollectibleIdToTrade,
        true, // Set active to true for the new owner
        receiverUserId,
        giverUserId);

    if (tradeSuccess) {
      if (!mounted) return;
      setState(() {
        _currentScanState = ScanState.success;
      });
      _successLottieController.forward();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _currentScanState = ScanState.received;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      // Reload collectibles for the receiver
      await collectibleModel.loadCollectibles();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: "Kloppocar Home",
          qrcode: tradeCode, // Pass the successfully processed trade code
          userData: widget.userData, // Or fetch updated user data
        ),
      ));
    } else {
      _handleTradeError(collectibleModel.errorMessage ??
          "Trade failed. The item might not be available or an error occurred.");
    }
  }

  void _handleTradeError(String message) async {
    if (!mounted) return;
    debugPrint('Trade Error: $message');
    setState(() {
      _currentScanState = ScanState.error;
    });
    // Show message to user via SnackBar or Dialog if preferred
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
    await Future.delayed(
        const Duration(seconds: 2)); // Keep error screen for a bit
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MyHomePage(
        title: "Kloppocar Home",
        qrcode: 'error',
        userData: widget.userData,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Calculate scan area size based on screen dimensions
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 330.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        title: const Text("Scan/Enter Collectible Code"),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontFamily: 'ChakraPetch',
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Stack(
        children: [
          // Display the appropriate widget based on the current scan state
          if (_currentScanState == ScanState.scanning)
            _buildScannerAndInput(scanArea),
          if (_currentScanState == ScanState.loading) _CodeLoadingWidget(),
          if (_currentScanState == ScanState.success)
            _CodeSuccessWidget(
                controller: _successLottieController,
                opacityTween: _opacityTween),
          if (_currentScanState == ScanState.error) _CodeErrorWidget(),
        ],
      ),
    );
  }

  /// Builds the QR scanner and manual code input UI.
  Widget _buildScannerAndInput(double scanArea) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            overlayBuilder: (context, constraints) => Align(
              alignment: Alignment.center,
              child: CustomPaint(
                foregroundPainter: BorderPainter(),
                child: SizedBox(
                  width: scanArea,
                  height: scanArea,
                ),
              ),
            ),
            controller: _scanController,
            onDetect: (barcode) {
              final String code = barcode.barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) {
                _processCode(code); // Process the scanned QR code
              }
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
                  labelText: 'Or enter code manually',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_codeTextController.text.isNotEmpty) {
                        _processCode(
                            _codeTextController.text); // Process manual input
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _processCode(value); // Process manual input on submit
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_codeTextController.text.isNotEmpty) {
                    _processCode(_codeTextController
                        .text); // Process manual input on button press
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 50), // Make button full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit Code'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the QR scan area border.
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
        ..color = const Color(0xffd622ca) // Pinkish purple color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// Widget to display the loading state.
class _CodeLoadingWidget extends StatelessWidget {
  const _CodeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Background color for loading screen
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Image.asset(
              'assets/images/deins_logo.png', // Ensure this asset path is correct
              height: 200,
              width: 200,
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              child: const Text(
                'Processing Code...',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: Lottie.asset(
                  'assets/lottie/pinkspin1.json'), // Ensure this asset path is correct
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display the success state with a Lottie animation.
class _CodeSuccessWidget extends StatelessWidget {
  const _CodeSuccessWidget({
    super.key,
    required this.controller,
    required this.opacityTween,
  });

  final AnimationController controller;
  final Tween<double> opacityTween;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Background color for success screen
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: 300,
          child: AnimatedOpacity(
            opacity: opacityTween.evaluate(controller),
            duration: const Duration(seconds: 2),
            child: Lottie.asset(
                'assets/lottie/success2.json'), // Ensure this asset path is correct
          ),
        ),
      ),
    );
  }
}

/// Widget to display the error state.
class _CodeErrorWidget extends StatelessWidget {
  const _CodeErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Background color for error screen
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error image
            Image.asset(
              'assets/images/negative.png', // Ensure this asset path is correct
              height: 200,
              width: 200,
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              child: const Text(
                'Incorrect Code!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
