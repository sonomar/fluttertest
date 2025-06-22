import 'package:flutter/material.dart';
import 'package:deins_app/helpers/mission_helper.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/collectible_model.dart';
import '../../api/user_collectible.dart';
import '../../models/app_auth_provider.dart';
import '../../models/user_model.dart';
import '../../helpers/localization_helper.dart';
import '../../main.dart';
import '../../helpers/get_random.dart';

// Enum and helper classes
enum ScanState { loading, success, error, received }

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

  @override
  void initState() {
    super.initState();
    _successLottieController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    // Immediately start processing the code when this screen is opened.
    _processCode(widget.code);
  }

  @override
  void dispose() {
    _successLottieController.dispose();
    super.dispose();
  }

  bool _isCodeValid(String code) {
    if (code.isEmpty) return false;
    final List<String> splitCode = code.split('-');
    return splitCode.isNotEmpty && splitCode[0] == 'deinsqr';
  }

  bool _isTradeCode(String code) {
    final List<String> parts = code.split('-');
    return parts.length == 4 &&
        (parts[0] == 'deinsQr' || parts[0] == 'deinsqr') &&
        parts[1] == 'trade';
  }

  Future<void> _processCode(String code) async {
    if (!mounted) return;

    if (_isTradeCode(code)) {
      await _processTrade(code);
    } else if (_isCodeValid(code)) {
      await _processRegularCode(code);
    } else {
      _handleError('Invalid code format.');
    }
  }

  Future<void> _processRegularCode(String code) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final collectibleModel =
        Provider.of<CollectibleModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    final List collectionCollectibles = collectibleModel.collectionCollectibles;
    final List userCollectiblesRaw = collectibleModel.userCollectibles;

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
      final SharedPreferences prefValue = await SharedPreferences.getInstance();
      await prefValue.setBool(code, true);

      // Get the userId directly and safely from the UserModel provider.
      final String? userId = userModel.currentUser?['userId']?.toString();

      // Add a null check to handle the case where the user might not be loaded yet.
      if (userId == null) {
        _handleError("Could not identify current user.");
        return;
      }

      final String collectibleId = code.split('-').last;

      final Map<String, dynamic>? foundCollectibleMap =
          collectionCollectibles.firstWhere(
        (c) => c["collectibleId"].toString() == collectibleId,
        orElse: () => null,
      );

      if (foundCollectibleMap == null) {
        _handleError('Collectible not found in collection.');
        return;
      }

      final CollectibleWrapper wrappedCollectible = CollectibleWrapper(
        foundCollectibleMap["collectibleId"].toString(),
        foundCollectibleMap["circulation"] as int,
      );

      final int? generatedMint = generateRandomMint(
        wrappedCollectible,
        userCollectiblesWrapped,
      );

      if (generatedMint == null) {
        _handleError('No available mints for this collectible.');
        return;
      }

      final String mint = generatedMint.toString();
      await collectibleModel.addUserCollectible(userId, collectibleId, mint);

      // The '!' is now safe because we've already checked that userId is not null.
      await updateMissionProgress(
        userId: userId,
        collectibleId: collectibleId,
        operation: MissionProgressOperation.increment,
        context: context,
      );

      _handleSuccess(code);
    } catch (e) {
      _handleError('Error processing collectible: $e');
    }
  }

  Future<void> _processTrade(String tradeCode) async {
    if (!mounted) return;

    final List<String> parts = tradeCode.split('-');
    String giverUserId = parts[2];
    String userCollectibleIdToTrade = parts[3];
    final userModel = Provider.of<UserModel>(context, listen: false);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final collectibleModel =
        Provider.of<CollectibleModel>(context, listen: false);
    final String? receiverUserId = userModel.currentUser?['userId']?.toString();

    if (receiverUserId == null) {
      _handleError("Could not identify current user to receive trade.");
      return;
    }

    if (receiverUserId == giverUserId) {
      _handleError("Cannot trade a collectible to yourself.");
      return;
    }

    final tradedInstanceData = await getUserCollectibleByUserCollectibleId(
        userCollectibleIdToTrade, authProvider);

    if (tradedInstanceData == null ||
        tradedInstanceData['collectibleId'] == null) {
      _handleError("Could not verify the collectible being traded.");
      return;
    }

    final String collectibleId = tradedInstanceData['collectibleId'].toString();
    bool tradeSuccess = await collectibleModel.updateUserCollectibleStatus(
        userCollectibleIdToTrade, true, receiverUserId, giverUserId);

    if (tradeSuccess) {
      await updateMissionProgress(
          userId: receiverUserId,
          collectibleId: collectibleId,
          operation: MissionProgressOperation.increment,
          context: context);
      await updateMissionProgress(
          userId: giverUserId,
          collectibleId: collectibleId,
          operation: MissionProgressOperation.decrement,
          context: context);

      _handleSuccess(tradeCode);
    } else {
      _handleError(collectibleModel.errorMessage ?? "Trade failed.");
    }
  }

  void _handleError(String message) async {
    debugPrint(message);
    if (!mounted) return;
    setState(() => _currentScanState = ScanState.error);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pop(); // Go back to the previous screen (ScanScreen)
  }

  void _handleSuccess(String code) async {
    if (!mounted) return;
    setState(() => _currentScanState = ScanState.success);
    _successLottieController.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _currentScanState = ScanState.received);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: "Kloppocar Home",
          qrcode: code,
          userData: widget.userData,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- START OF FIX ---
    // The switch statement now has a default case to ensure it always returns a widget.
    switch (_currentScanState) {
      case ScanState.loading:
        return const _CodeLoadingWidget();
      case ScanState.success:
        return _CodeSuccessWidget(
            controller: _successLottieController, opacityTween: _opacityTween);
      case ScanState.error:
        return const _CodeErrorWidget();
      case ScanState.received:
        return const _CodeLoadingWidget();
      default:
        // This default case handles any unexpected state and prevents the error.
        return const _CodeErrorWidget();
    }
    // --- END OF FIX ---
  }
}

// --- UI Widgets for different states ---

class _CodeLoadingWidget extends StatelessWidget {
  const _CodeLoadingWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/deins_logo.png',
                height: 200, width: 200),
            const SizedBox(height: 20),
            const Text('Processing Code...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
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
    return Container(
      color: Colors.black,
      child: Center(
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
  const _CodeErrorWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/negative.png', height: 200, width: 200),
            const SizedBox(height: 20),
            const Text('Incorrect Code!',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
