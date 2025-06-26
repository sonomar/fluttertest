import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../models/mission_model.dart';
import '../../screens/subscreens/missions/award_screen.dart';

// Enum to manage the visual state of the screen
enum AwardProcessingState { processing, success, error }

class AwardProcessingScreen extends StatefulWidget {
  final dynamic selectedAward;
  final dynamic selectedAwardUser;

  const AwardProcessingScreen({
    super.key,
    required this.selectedAward,
    required this.selectedAwardUser,
  });

  @override
  State<AwardProcessingScreen> createState() => _AwardProcessingScreenState();
}

class _AwardProcessingScreenState extends State<AwardProcessingScreen>
    with TickerProviderStateMixin {
  AwardProcessingState _currentState = AwardProcessingState.processing;
  late final AnimationController _successController;
  String _errorMessage = "An unknown error occurred.";

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for the success Lottie file.
    _successController = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 6), // The duration of the success animation.
    );
    // Start the award claim process as soon as the screen loads.
    _processAwardClaim();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  /// Handles the logic for claiming the award by calling the MissionModel.
  Future<void> _processAwardClaim() async {
    // A small delay to allow the initial "processing" animation to be seen.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final missionModel = context.read<MissionModel>();
    bool success =
        await missionModel.updateMissionCompletion(widget.selectedAwardUser);

    if (success) {
      _handleSuccess();
    } else {
      _handleError(missionModel.errorMessage ?? "Failed to claim reward.");
    }
  }

  /// Handles the UI transition and navigation on a successful claim.
  void _handleSuccess() async {
    if (!mounted) return;
    setState(() => _currentState = AwardProcessingState.success);

    // Wait for the success animation to complete before navigating.
    await _successController.forward();
    if (!mounted) return;

    // Navigate to the AwardScreen, clearing the navigation stack.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AwardScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Handles the UI transition on a failed claim.
  void _handleError(String message) async {
    if (!mounted) return;
    setState(() {
      _currentState = AwardProcessingState.error;
      _errorMessage = message;
    });
    // Wait for 3 seconds to show the error message.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    // Go back to the previous screen.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // The main build method returns a Scaffold with a black background.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  /// A helper method to build the content based on the current state.
  Widget _buildContent() {
    switch (_currentState) {
      case AwardProcessingState.processing:
        return _ProcessingWidget();
      case AwardProcessingState.success:
        return _SuccessWidget(
          controller: _successController,
          imageUrl: widget.selectedAward['imgRef']['load'],
        );
      case AwardProcessingState.error:
        return _ErrorWidget(message: _errorMessage);
      default:
        return _ErrorWidget(message: "An unexpected error occurred.");
    }
  }
}

// --- UI Widgets for different states ---

class _ProcessingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/deins_logo.png', height: 200, width: 200),
        const SizedBox(height: 20),
        const Text('Claiming Your Reward...',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 20),
        SizedBox(
            height: 40,
            width: 40,
            child: Lottie.asset('assets/lottie/pinkspin1.json')),
      ],
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  final AnimationController controller;
  final String imageUrl;

  const _SuccessWidget({required this.controller, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Use a Stack to overlay the award image on top of the Lottie animation.
    return Stack(
      alignment: Alignment.center,
      children: [
        // The success checkmark animation is the bottom layer.
        Lottie.asset('assets/lottie/success2.json',
            controller: controller, width: 300),
        // Fade in the award image as the checkmark animation plays.
        FadeTransition(
          opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn),
          child: Image.network(imageUrl, height: 300),
        ),
      ],
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/negative.png', height: 200, width: 200),
        const SizedBox(height: 20),
        Text(
          'Claim Failed!',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
