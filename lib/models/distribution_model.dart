import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
import '../models/user_model.dart';
import '../api/distribution.dart';
import '../api/distribution_code.dart';
import '../api/distribution_code_user.dart';
import '../api/distribution_collectible.dart';
import '../api/user_collectible.dart';

class DistributionModel extends ChangeNotifier {
  final AppAuthProvider _appAuthProvider;
  final UserModel userModel;

  bool _isLoading = false;
  String? _errorMessage;
  String? _loadingMessage;

  // Caches user's redeemed codes to prevent re-fetching on every scan.
  List<dynamic> _userDistributionCodeUsers = [];
  bool _hasLoadedUserCodes = false;

  DistributionModel(this._appAuthProvider, this.userModel);

  // Getters for private state variables
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get loadingMessage => _loadingMessage;

  void _setState(
      {bool isLoading = false, String? error, String? loadingMessage}) {
    _isLoading = isLoading;
    _errorMessage = error;
    _loadingMessage = loadingMessage;
    notifyListeners();
  }

  /// Fetches all of a user's redeemed codes to check against new scans.
  Future<void> _loadUserRedeemedCodes({bool forceReload = false}) async {
    if (_hasLoadedUserCodes && !forceReload) return;

    final String? userId = userModel.currentUser?['userId']?.toString();
    if (userId == null) {
      throw Exception("Current user not found.");
    }

    try {
      final codes =
          await getDistributionCodeUsersByUserId(userId, _appAuthProvider);
      if (codes is List) {
        _userDistributionCodeUsers = codes;
        _hasLoadedUserCodes = true;
      }
    } catch (e) {
      _errorMessage = "Could not load user's redeemed codes: ${e.toString()}";
      print(_errorMessage);
    }
    notifyListeners();
  }

  /// Handles the process of a user scanning or typing a code to get a collectible.
  Future<bool> redeemScannedCode(String code) async {
    _setState(isLoading: true, loadingMessage: "Verifying code...");
    final String? userId = userModel.currentUser?['userId']?.toString();

    try {
      if (userId == null) throw Exception("User ID not available.");
      await _loadUserRedeemedCodes();

      // 1. Get the distribution code details
      final distributionCode =
          await getDistributionCodeByCode(code, _appAuthProvider);
      if (distributionCode == null) throw Exception("Invalid code.");

      final distributionCodeId =
          distributionCode['distributionCodeId'].toString();
      final distributionId = distributionCode['distributionId'].toString();

      // 2. Check if user has already redeemed this specific code
      final hasRedeemed = _userDistributionCodeUsers
          .any((c) => c['distributionCodeId'].toString() == distributionCodeId);
      if (hasRedeemed) throw Exception("You have already redeemed this code.");

      // 3. Get the pool of collectibles associated with this distribution
      final collectiblePool = await getDistributionCollectiblesByDistributionId(
          distributionId, _appAuthProvider);
      if (collectiblePool == null || collectiblePool.isEmpty) {
        throw Exception("No collectibles are associated with this code.");
      }

      // 4. Randomly select one collectible to award from the pool
      final randomCollectible =
          collectiblePool[Random().nextInt(collectiblePool.length)];
      final collectibleToAwardId =
          randomCollectible['collectibleId'].toString();

      // 5. Create the user redemption record
      await createDistributionCodeUser({
        "userId": userId,
        "distributionCodeId": distributionCodeId,
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
      }, _appAuthProvider);

      // 6. Award the new collectible to the user
      await createUserCollectible(userId, collectibleToAwardId, 0,
          _appAuthProvider); // Assuming mint '0' for now

      _setState(
          isLoading: false, loadingMessage: "Success! Collectible added.");
      return true;
    } catch (e) {
      _setState(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Handles creating a single-use code for transferring a collectible.
  Future<Map<String, dynamic>?> initiateTransfer(
      String userCollectibleId, String transferDistributionId) async {
    _setState(isLoading: true, loadingMessage: "Generating transfer code...");

    try {
      final Map<String, dynamic> body = {
        "distributionId": transferDistributionId,
        "code":
            "TFR-${DateTime.now().millisecondsSinceEpoch}", // Example code generation
        "isMultiUse": false,
        // IMPORTANT: Assumed field to link the specific collectible instance
        "userCollectibleId": userCollectibleId
      };

      final newCode = await createDistributionCode(body, _appAuthProvider);
      _setState(isLoading: false);
      return newCode;
    } catch (e) {
      _setState(
          isLoading: false,
          error: "Failed to create transfer code: ${e.toString()}");
      return null;
    }
  }

  /// Handles completing a transfer after a user scans the code.
  Future<bool> completeTransfer(String code) async {
    _setState(isLoading: true, loadingMessage: "Completing transfer...");
    final String? newOwnerId = userModel.currentUser?['userId']?.toString();

    try {
      if (newOwnerId == null) throw Exception("Current user not found.");

      // 1. Get the distribution code details. This must contain the userCollectibleId.
      final distributionCode =
          await getDistributionCodeByCode(code, _appAuthProvider);
      if (distributionCode == null) throw Exception("Invalid transfer code.");

      final userCollectibleId =
          distributionCode['userCollectibleId']?.toString();
      if (userCollectibleId == null) {
        throw Exception("Transfer code is not linked to a collectible.");
      }

      // 2. Check if code has already been used
      final existingUsers = await getDistributionCodeUsersByDistributionCodeId(
          distributionCode['distributionCodeId'], _appAuthProvider);
      if (existingUsers != null && existingUsers.isNotEmpty) {
        throw Exception("This transfer code has already been used.");
      }

      // 3. Create the redemption record for the new owner
      await createDistributionCodeUser({
        "userId": newOwnerId,
        "distributionCodeId": distributionCode['distributionCodeId'],
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
      }, _appAuthProvider);

      // 4. Update the owner of the UserCollectible
      await updateUserCollectibleByUserCollectibleId(
          {"userCollectibleId": userCollectibleId, "ownerId": newOwnerId},
          _appAuthProvider);

      _setState(isLoading: false, loadingMessage: "Transfer complete!");
      return true;
    } catch (e) {
      _setState(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Handles giving a user a collectible reward, e.g. for completing a mission.
  Future<bool> redeemMissionReward(
      {required String missionDistributionId}) async {
    _setState(isLoading: true, loadingMessage: "Claiming mission reward...");
    final String? userId = userModel.currentUser?['userId']?.toString();

    try {
      if (userId == null) throw Exception("User not found.");

      // 1. Get the pool of collectibles associated with this mission's distribution
      final collectiblePool = await getDistributionCollectiblesByDistributionId(
          missionDistributionId, _appAuthProvider);
      if (collectiblePool == null || collectiblePool.isEmpty) {
        throw Exception("No rewards are associated with this mission.");
      }

      // 2. Randomly select one collectible to award from the pool
      final randomCollectible =
          collectiblePool[Random().nextInt(collectiblePool.length)];
      final collectibleToAwardId =
          randomCollectible['collectibleId'].toString();

      // 3. Create a unique, single-use code for this user and distribution
      final newCode = await createDistributionCode({
        "distributionId": missionDistributionId,
        "code":
            "MISSION-$missionDistributionId-$userId-${DateTime.now().millisecondsSinceEpoch}",
        "isMultiUse": false,
      }, _appAuthProvider);

      // 4. Immediately redeem it for the user
      await createDistributionCodeUser({
        "userId": userId,
        "distributionCodeId": newCode['distributionCodeId'],
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
      }, _appAuthProvider);

      // 5. Create the new UserCollectible for the user
      await createUserCollectible(
          userId, collectibleToAwardId, 0, _appAuthProvider); // Assuming mint 0

      _setState(isLoading: false, loadingMessage: "Reward collected!");
      return true;
    } catch (e) {
      _setState(
          isLoading: false, error: "Failed to claim reward: ${e.toString()}");
      return false;
    }
  }
}
