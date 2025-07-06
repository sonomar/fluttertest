import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../helpers/localization_helper.dart';
import '../../../models/mission_model.dart';
import '../../../models/collectible_model.dart';
import '../../../models/distribution_model.dart'; // Import DistributionModel
import '../../../models/user_model.dart';
import '../../../main.dart';

// Enum to manage the visual state of the screen
enum AwardProcessingState { processing, success, finalizing, error }

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
  String _errorMessage =
      "An unknown error occurred."; // This will be set with context later

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _processAwardClaim();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _processAwardClaim() async {
    // Wait for animations
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;

    final missionModel = context.read<MissionModel>();

    // 1. First, process the primary mission completion.
    bool missionSuccess =
        await missionModel.updateMissionCompletion(widget.selectedAwardUser);

    if (missionSuccess) {
      // 2. If the mission is claimed, check for an additional distribution reward.
      final rewardId = widget.selectedAward['rewardId'];

      // Check if a valid rewardId exists (is not null and is a positive integer)
      if (rewardId != null && rewardId is int && rewardId > 0) {
        final distributionModel = context.read<DistributionModel>();

        // 3. Attempt to redeem the distribution-based reward.
        bool distributionSuccess = await distributionModel.redeemMissionReward(
            context: context, missionDistributionId: rewardId.toString());

        if (!distributionSuccess) {
          // Optional: Log an error if the bonus reward fails.
          // The user experience will still proceed as successful because the main mission was claimed.
          print(
              "Mission claimed successfully, but failed to grant distribution reward: ${distributionModel.errorMessage}");
        }
      }

      // 4. Proceed to the success screen.
      _handleSuccess();
    } else {
      _handleError(missionModel.errorMessage ??
          translate("award_processing_process_failfallback", context));
    }
  }

  /// Handles the UI transition and data refresh on a successful claim.
  void _handleSuccess() async {
    if (!mounted) return;
    setState(() => _currentState = AwardProcessingState.success);

    await _successController.forward();
    if (!mounted) return;

    // Add a finalizing step to show the user that data is being synced.
    setState(() => _currentState = AwardProcessingState.finalizing);

    // Force-refresh both the mission and collectible models.
    try {
      await Future.wait([
        context.read<MissionModel>().loadMissions(),
        context.read<CollectibleModel>().loadCollectibles(forceClear: true),
      ]);
    } catch (e) {
      print("Error during final data refresh after award claim: $e");
    }

    if (!mounted) return;
    final userData = context.read<UserModel>().currentUser;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: translate("code_proc_success_hometitle", context),
          qrcode: "award_claimed",
          userData: userData,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _handleError(String message) async {
    if (!mounted) return;
    setState(() {
      _currentState = AwardProcessingState.error;
      _errorMessage = message;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case AwardProcessingState.processing:
        return _ProcessingWidget();
      case AwardProcessingState.success:
        return _SuccessWidget(
          controller: _successController,
          imageUrl: widget.selectedAward['imgRef']['load'],
        );
      case AwardProcessingState.finalizing:
        return _FinalizingWidget();
      case AwardProcessingState.error:
        return _ErrorWidget(message: _errorMessage);
      default:
        return _ErrorWidget(
            message:
                translate("auth_error_helper_simplify_unexpected", context));
    }
  }
}

// --- UI Widgets for different states (unchanged) ---

class _ProcessingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/deins_logo.png', height: 200, width: 200),
        const SizedBox(height: 20),
        Text(translate("award_processing_widget_claiming", context),
            style: const TextStyle(color: Colors.white, fontSize: 16)),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset('assets/lottie/success2.json',
            controller: controller, width: 300),
        FadeTransition(
          opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn),
          child: Image.network(imageUrl, height: 400),
        ),
      ],
    );
  }
}

class _FinalizingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/deins_logo.png', height: 200, width: 200),
        const SizedBox(height: 20),
        Text(translate("award_processing_widget_updating", context),
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 20),
        SizedBox(
            height: 40,
            width: 40,
            child: Lottie.asset('assets/lottie/pinkspin1.json')),
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
          translate("award_processing_widget_claimfailed", context),
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
