import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../helpers/localization_helper.dart';
import '../../models/distribution_model.dart';
import '../../main.dart';

enum ScanState { loading, success, error, received }

class CodeProcessingScreen extends StatefulWidget {
  final String code;
  final dynamic userData;

  const CodeProcessingScreen({super.key, required this.code, this.userData});

  @override
  State<CodeProcessingScreen> createState() => _CodeProcessingScreenState();
}

class _CodeProcessingScreenState extends State<CodeProcessingScreen>
    with SingleTickerProviderStateMixin {
  ScanState _currentScanState = ScanState.loading;
  late final AnimationController _successLottieController;
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0, end: 0.0);
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _successLottieController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _processCode(widget.code);
  }

  @override
  void dispose() {
    _successLottieController.dispose();
    super.dispose();
  }

  /// Determines if a code is for a transfer based on its prefix.
  bool _isTransferCode(String code) {
    return code.startsWith('TFR-');
  }

  /// Main logic router.
  Future<void> _processCode(String code) async {
    if (!mounted) return;
    final distributionModel = context.read<DistributionModel>();

    bool success = false;
    if (_isTransferCode(code)) {
      final result = await distributionModel.completeTransfer(code, context);
      success = result != null;
    } else {
      final result = await distributionModel.redeemScannedCode(code, context);
      success = result != null;
    }

    if (!mounted) return;

    // After the operation, check the model's state.
    if (success) {
      _handleSuccess(code);
    } else {
      _handleError(distributionModel);
    }
  }

  void _handleError(DistributionModel model) async {
    if (!mounted) return;
    setState(() {
      final errorKey = model.errorMessage ?? "code_proc_redeem_invalidfallback";
      _errorMessage = translate(errorKey, context);
      _currentScanState = ScanState.error;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _handleSuccess(String code) async {
    if (!mounted) return;
    setState(() => _currentScanState = ScanState.success);
    await _successLottieController.forward();
    if (!mounted) return;
    setState(() => _currentScanState = ScanState.received);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: translate("code_proc_success_hometitle", context),
          qrcode: code,
          userData: widget.userData,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScanState) {
      case ScanState.loading:
        return const _CodeLoadingWidget();
      case ScanState.success:
        return _CodeSuccessWidget(
            controller: _successLottieController, opacityTween: _opacityTween);
      case ScanState.error:
        return _CodeErrorWidget(message: _errorMessage);
      case ScanState.received:
        return const _CodeLoadingWidget(); // Shows loading while redirecting
    }
  }
}

// --- UI Widgets for different states (unchanged) ---

class _CodeLoadingWidget extends StatelessWidget {
  const _CodeLoadingWidget();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/deins_logo.png',
                height: 200, width: 200),
            const SizedBox(height: 20),
            Text(translate("code_proc_widget_processing", context),
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
                height: 40,
                width: 40,
                child: Lottie.asset('assets/lottie/pinkspin1.json')),
          ],
        ),
      ),
    );
  }
}

class _CodeSuccessWidget extends StatelessWidget {
  const _CodeSuccessWidget(
      {required this.controller, required this.opacityTween});
  final AnimationController controller;
  final Tween<double> opacityTween;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added Scaffold for proper rendering
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: opacityTween.evaluate(controller),
          duration: const Duration(seconds: 2),
          child: Lottie.asset('assets/lottie/success2.json', width: 300),
        ),
      ),
    );
  }
}

class _CodeErrorWidget extends StatelessWidget {
  final String message;
  const _CodeErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/negative.png', height: 200, width: 200),
            const SizedBox(height: 20),
            Text(message, // Display the specific error message from the model
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
