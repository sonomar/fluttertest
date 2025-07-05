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

  List<dynamic> _userDistributionCodeUsers = [];
  bool _hasLoadedUserCodes = false;

  DistributionModel(this._appAuthProvider, this.userModel);

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

  Future<void> loadUserRedeemedCodes({bool forceReload = false}) async {
    if (_hasLoadedUserCodes && !forceReload) return;
    final String? userId = userModel.currentUser?['userId']?.toString();
    if (userId == null) return;

    try {
      final codes =
          await getDistributionCodeUsersByUserId(userId, _appAuthProvider);
      if (codes is List) {
        _userDistributionCodeUsers = codes;
        _hasLoadedUserCodes = true;
      }
    } catch (e) {
      print("Could not load user's redeemed codes: ${e.toString()}");
    }
  }

  Future<String?> redeemScannedCode(String code) async {
    _setState(isLoading: true, loadingMessage: "Verifying code...");
    final String? userId = userModel.currentUser?['userId']?.toString();

    try {
      if (userId == null) throw Exception("User ID not available.");
      await loadUserRedeemedCodes();

      final distributionCode =
          await getDistributionCodeByCode(code, _appAuthProvider);
      if (distributionCode == null) throw Exception("Invalid code.");

      final distributionCodeId =
          distributionCode['distributionCodeId'].toString();
      final distributionId = distributionCode['distributionId'].toString();

      // Fetch existing redemptions for this specific code to check usage limits.
      final existingRedemptions =
          await getDistributionCodeUsersByDistributionCodeId(
              distributionCodeId, _appAuthProvider);
      final redemptionCount =
          existingRedemptions is List ? existingRedemptions.length : 0;

      final bool isMultiUse = distributionCode['isMultiUse'] ?? false;

      if (!isMultiUse) {
        // Single-use code logic
        if (redemptionCount >= 1) {
          throw Exception("This code has already been used.");
        }
      } else {
        // Multi-use code logic
        final int? multiUseQty = distributionCode['multiUseQty'];
        // A null or zero quantity means infinite uses.
        if (multiUseQty != null && multiUseQty > 0) {
          if (redemptionCount >= multiUseQty) {
            throw Exception(
                "This code has reached its maximum number of uses.");
          }
        }
      }

      final distribution = await getDistributionByDistributionId(
          distributionId, _appAuthProvider);
      if (distribution == null) {
        throw Exception("Could not verify the code's campaign details.");
      }

      final now = DateTime.now();
      final startDateString = distribution['startDate'] as String?;
      final endDateString = distribution['endDate'] as String?;

      if (startDateString != null && startDateString.isNotEmpty) {
        final startDate = DateTime.parse(startDateString);
        if (now.isBefore(startDate)) {
          throw Exception("This promotion has not started yet.");
        }
      }

      if (endDateString != null && endDateString.isNotEmpty) {
        final endDate = DateTime.parse(endDateString);
        if (now.isAfter(endDate)) {
          throw Exception("This promotion has expired.");
        }
      }

      final hasRedeemed = _userDistributionCodeUsers
          .any((c) => c['distributionCodeId'].toString() == distributionCodeId);
      if (hasRedeemed) throw Exception("You have already redeemed this code.");

      final collectiblePool = await getDistributionCollectiblesByDistributionId(
          distributionId, _appAuthProvider);
      if (collectiblePool == null || collectiblePool.isEmpty) {
        throw Exception("No collectibles are associated with this code.");
      }

      final randomCollectible =
          collectiblePool[Random().nextInt(collectiblePool.length)];
      final collectibleToAwardId =
          randomCollectible['collectibleId'].toString();

      await createDistributionCodeUser({
        "userId": userId,
        "distributionCodeId": distributionCodeId,
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
      }, _appAuthProvider);

      await createUserCollectible(
          userId, collectibleToAwardId, 0, _appAuthProvider);

      _setState(
          isLoading: false, loadingMessage: "Success! Collectible added.");
      return collectibleToAwardId;
    } catch (e) {
      _setState(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> initiateTransfer(
      String userCollectibleId, String transferDistributionId) async {
    _setState(isLoading: true, loadingMessage: "Generating transfer code...");
    try {
      final Map<String, dynamic> body = {
        "distributionId": transferDistributionId,
        "code": "TFR-${DateTime.now().millisecondsSinceEpoch}",
        "isMultiUse": false,
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

  /// Returns a map with 'collectibleId' and 'giverId' on success, otherwise null.
  Future<Map<String, String>?> completeTransfer(String code) async {
    _setState(isLoading: true, loadingMessage: "Completing transfer...");
    final String? newOwnerId = userModel.currentUser?['userId']?.toString();

    try {
      if (newOwnerId == null) throw Exception("Current user not found.");

      final distributionCode =
          await getDistributionCodeByCode(code, _appAuthProvider);
      if (distributionCode == null) throw Exception("Invalid transfer code.");

      final distributionCodeId =
          distributionCode['distributionCodeId'].toString();

      final existingRedemptions =
          await getDistributionCodeUsersByDistributionCodeId(
              distributionCodeId, _appAuthProvider);
      if (existingRedemptions is List && existingRedemptions.isNotEmpty) {
        throw Exception("This transfer code has already been used.");
      }

      final userCollectibleId =
          distributionCode['userCollectibleId']?.toString();
      if (userCollectibleId == null)
        throw Exception("Transfer code is not linked to a collectible.");

      final existingUsers = await getDistributionCodeUsersByDistributionCodeId(
          distributionCode['distributionCodeId'], _appAuthProvider);
      if (existingUsers != null && existingUsers.isNotEmpty) {
        throw Exception("This transfer code has already been used.");
      }

      // Fetch the collectible instance to get giverId and collectibleId
      final tradedInstanceData = await getUserCollectibleByUserCollectibleId(
          userCollectibleId, _appAuthProvider);
      if (tradedInstanceData == null)
        throw Exception("Could not find collectible to be traded.");

      final String giverId = tradedInstanceData['ownerId'].toString();
      final String collectibleId =
          tradedInstanceData['collectibleId'].toString();

      if (newOwnerId == giverId) {
        throw Exception("Cannot trade a collectible to yourself.");
      }

      await createDistributionCodeUser({
        "userId": newOwnerId,
        "distributionCodeId": distributionCode['distributionCodeId'],
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
      }, _appAuthProvider);

      await updateUserCollectibleByUserCollectibleId(
          {"userCollectibleId": userCollectibleId, "ownerId": newOwnerId},
          _appAuthProvider);

      _setState(isLoading: false, loadingMessage: "Transfer complete!");
      return {
        'collectibleId': collectibleId,
        'giverId': giverId
      }; // Return data for mission progress
    } catch (e) {
      _setState(isLoading: false, error: e.toString());
      return null; // Return null on failure
    }
  }

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
