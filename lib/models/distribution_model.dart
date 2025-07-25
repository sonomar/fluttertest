import 'dart:math';
import 'package:flutter/material.dart';
import '../helpers/mission_helper.dart';
import '../helpers/get_random.dart';
import '../models/app_auth_provider.dart';
import '../models/user_model.dart';
import '../api/distribution.dart';
import '../api/distribution_code.dart';
import '../api/distribution_code_user.dart';
import '../api/distribution_collectible.dart';
import '../api/user_collectible.dart';
import '../api/collectible.dart';

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

  void clearData() {
    _userDistributionCodeUsers = [];
    _hasLoadedUserCodes = false;
    _isLoading = false;
    _errorMessage = null;
    _loadingMessage = null;
    notifyListeners();
    print("DistributionModel: Data cleared.");
  }

  Future<void> loadUserRedeemedCodes({bool forceReload = false}) async {
    if (_isLoading) return;
    final String? userId = userModel.currentUser?['userId']?.toString();
    if (userId == null) {
      _isLoading = false; // Reset loading state
      return;
    }

    try {
      final codes =
          await getDistributionCodeUsersByUserId(userId, _appAuthProvider);
      if (codes is List) {
        _userDistributionCodeUsers = codes;
        _hasLoadedUserCodes = true;
      }
    } catch (e) {
      print("Could not load user's redeemed codes: ${e.toString()}");
    } finally {
      _isLoading = false; // Always reset loading state
      // notifyListeners(); // Optional: uncomment if a screen needs to react to this load.
    }
  }

  Future<String?> redeemScannedCode(String code, BuildContext context) async {
    _setState(isLoading: true, loadingMessage: "dist_model_redeem_verifying");
    final String? userId = userModel.currentUser?['userId']?.toString();

    try {
      if (userId == null) throw Exception("dist_model_redeem_nouser");

      await loadUserRedeemedCodes();

      dynamic rawDistributionCode =
          await getDistributionCodeByCode(code, _appAuthProvider);
      if (rawDistributionCode is List) {
        if (rawDistributionCode.isEmpty)
          throw Exception("dist_model_redeem_invalid");
        rawDistributionCode = rawDistributionCode.first;
      }
      if (rawDistributionCode == null ||
          rawDistributionCode is! Map<String, dynamic>) {
        throw Exception("Invalid code.");
      }
      final Map<String, dynamic> distributionCode = rawDistributionCode;

      final distributionCodeId =
          distributionCode['distributionCodeId'].toString();
      final distributionId = distributionCode['distributionId'].toString();

      final distribution = await getDistributionByDistributionId(
          distributionId, _appAuthProvider);
      if (distribution == null) {
        throw Exception("dist_model_redeem_nocampaign");
      }

      List<dynamic> collectiblePool = [];
      final bool isRandom = distribution['isRandom'] ?? false;

      if (isRandom) {
        final collectionId = distribution['collectionId']?.toString();
        if (collectionId == null) {
          throw Exception("dist_model_random_nocollection");
        }
        final result =
            await getCollectiblesByCollectionId(collectionId, _appAuthProvider);
        if (result is List) {
          collectiblePool = result;
        }
      } else {
        final result = await getDistributionCollectiblesByDistributionId(
            distributionId, _appAuthProvider);
        if (result is List) {
          collectiblePool = result;
        }
      }

      if (collectiblePool.isEmpty) {
        throw Exception("dist_model_redeem_nocollectibles");
      }

      final randomItemFromPool =
          collectiblePool[Random().nextInt(collectiblePool.length)];

      Map<String, dynamic> collectibleForMinting;
      String collectibleToAwardId;

      if (isRandom) {
        // If random from a collection, the item is already a full collectible object.
        collectibleForMinting = randomItemFromPool;
        collectibleToAwardId =
            collectibleForMinting['collectibleId'].toString();
      } else {
        // If from a distribution, the item is a distributionCollectible.
        // We need to fetch the full collectible object to get its details (like circulation).
        collectibleToAwardId = randomItemFromPool['collectibleId'].toString();

        dynamic fetchedCollectible = await getCollectibleByCollectibleId(
            collectibleToAwardId, _appAuthProvider);
        if (fetchedCollectible == null) {
          throw Exception("dist_model_get_collectible_fail");
        }
        // Handle API potentially returning a list
        if (fetchedCollectible is List) {
          if (fetchedCollectible.isEmpty) {
            throw Exception("dist_model_get_collectible_fail");
          }
          collectibleForMinting = fetchedCollectible.first;
        } else {
          collectibleForMinting = fetchedCollectible;
        }
      }

      final existingRedemptions =
          await getDistributionCodeUsersByDistributionCodeId(
              distributionCodeId, _appAuthProvider);
      final redemptionCount =
          existingRedemptions is List ? existingRedemptions.length : 0;

      final bool isMultiUseCode = distributionCode['isMultiUse'] ?? false;

      if (!isMultiUseCode) {
        if (redemptionCount >= 1) {
          throw Exception("dist_model_redeem_alreadyredeemed");
        }
      } else {
        final int? multiUseQty = distributionCode['multiUseQty'];
        if (multiUseQty != null && multiUseQty > 0) {
          if (redemptionCount >= multiUseQty) {
            throw Exception("dist_model_max_uses");
          }
        }
      }

      final now = DateTime.now();
      final startDateString = distribution['startDate'] as String?;
      final endDateString = distribution['endDate'] as String?;

      if (startDateString != null && startDateString.isNotEmpty) {
        final startDate = DateTime.parse(startDateString);
        if (now.isBefore(startDate)) {
          throw Exception("dist_model_redeem_notstarted");
        }
      }

      if (endDateString != null && endDateString.isNotEmpty) {
        final endDate = DateTime.parse(endDateString);
        if (now.isAfter(endDate)) {
          throw Exception("dist_model_redeem_expired");
        }
      }
      final userRedemptionRecord = _userDistributionCodeUsers.firstWhere(
        (uc) => uc['distributionCodeId'].toString() == distributionCodeId,
        orElse: () => null, // Return null if not found
      );
      if (userRedemptionRecord != null &&
          (userRedemptionRecord['redeemed'] == true ||
              userRedemptionRecord['redeemed'] == 1)) {
        throw Exception("dist_model_redeem_alreadyredeemed");
      }
      final allUserCollectibles =
          await getUserCollectiblesByOwnerId(userId, _appAuthProvider);
      final int? newMint =
          generateRandomMint(collectibleForMinting, allUserCollectibles);
      if (newMint == null) {
        throw Exception("dist_model_no_mints");
      }
      final collectibleReceivedJson = {'collectibleId': collectibleToAwardId};

      if (userRedemptionRecord != null) {
        // Update the existing record that was reset.
        final body = {
          "distributionCodeUserId":
              userRedemptionRecord['distributionCodeUserId'],
          "redeemed": true,
          "redeemedDate": DateTime.now().toIso8601String(),
          "collectibleReceived": collectibleReceivedJson,
        };
        await updateDistributionCodeUserByDistributionCodeUserId(
            body, _appAuthProvider);
      } else {
        // Create a new record if one doesn't exist for this user.
        await createDistributionCodeUser({
          "userId": userId,
          "distributionCodeId": distributionCodeId,
          "redeemed": true,
          "redeemedDate": DateTime.now().toIso8601String(),
          "collectibleReceived": collectibleReceivedJson,
        }, _appAuthProvider);
      }

      await updateMissionProgress(
        userId: userId,
        collectibleId: collectibleToAwardId,
        operation: MissionProgressOperation.increment,
        context: context,
      );

      await createUserCollectible(
          userId, collectibleToAwardId, newMint, _appAuthProvider);

      _setState(isLoading: false, loadingMessage: "dist_model_redeem_success");
      return collectibleToAwardId;
    } catch (e) {
      final errorKey = e.toString().replaceFirst('Exception: ', '');
      _setState(isLoading: false, error: errorKey);
      return null;
    }
  }

  Future<Map<String, dynamic>?> initiateTransfer(
      String userCollectibleId, String transferDistributionId) async {
    final qrCodeJson = {'userCollectibleId': userCollectibleId};
    _setState(
        isLoading: true, loadingMessage: "dist_model_inittransfer_generating");
    try {
      final Map<String, dynamic> body = {
        "distributionId": transferDistributionId,
        "code": "TFR-${DateTime.now().millisecondsSinceEpoch}",
        "isMultiUse": false,
        "qrCode": qrCodeJson
      };
      print('test2: $body');
      final newCode = await createDistributionCode(body, _appAuthProvider);
      _setState(isLoading: false);
      return newCode;
    } catch (e) {
      final errorKey = e.toString().replaceFirst('Exception: ', '');
      print("Failed to create transfer code: $errorKey");
      _setState(isLoading: false, error: errorKey);
      return null;
    }
  }

  Future<Map<String, String>?> completeTransfer(
      String code, BuildContext context) async {
    _setState(
        isLoading: true,
        loadingMessage: "dist_model_completetransfer_completing");
    final String? newOwnerId = userModel.currentUser?['userId']?.toString();

    try {
      if (newOwnerId == null) {
        throw Exception("dist_model_completetransfer_nouser");
      }

      dynamic rawDistributionCode =
          await getDistributionCodeByCode(code, _appAuthProvider);
      if (rawDistributionCode is List) {
        if (rawDistributionCode.isEmpty) {
          throw Exception("dist_model_completetransfer_invalid");
        }
        rawDistributionCode = rawDistributionCode.first;
      }
      if (rawDistributionCode == null ||
          rawDistributionCode is! Map<String, dynamic>) {
        throw Exception("dist_model_completetransfer_invalid");
      }
      final Map<String, dynamic> distributionCode = rawDistributionCode;

      final distributionCodeId =
          distributionCode['distributionCodeId'].toString();

      final existingRedemptions =
          await getDistributionCodeUsersByDistributionCodeId(
              distributionCodeId, _appAuthProvider);
      if (existingRedemptions is List && existingRedemptions.isNotEmpty) {
        throw Exception("dist_model_completetransfer_used");
      }

      final qrCodeData = distributionCode['qrCode'] as Map<String, dynamic>?;
      if (qrCodeData == null) {
        throw Exception("dist_model_transfer_nolink_instance");
      }
      final userCollectibleId = qrCodeData['userCollectibleId']?.toString();
      if (userCollectibleId == null) {
        throw Exception("dist_model_completetransfer_nolink");
      }

      final tradedInstanceDataResponse =
          await getUserCollectibleByUserCollectibleId(
              userCollectibleId, _appAuthProvider);

      Map<String, dynamic>? tradedInstanceData;

      if (tradedInstanceDataResponse is List) {
        if (tradedInstanceDataResponse.isNotEmpty) {
          tradedInstanceData = tradedInstanceDataResponse.first;
        }
      } else if (tradedInstanceDataResponse is Map<String, dynamic>) {
        tradedInstanceData = tradedInstanceDataResponse;
      }
      if (tradedInstanceData == null) {
        throw Exception("dist_model_completetransfer_notfound");
      }

      final String giverId = tradedInstanceData['ownerId'].toString();
      final String collectibleId =
          tradedInstanceData['collectibleId'].toString();

      if (newOwnerId == giverId) {
        throw Exception("dist_model_completetransfer_selftrade");
      }
      final collectibleReceivedJson = {'collectibleId': collectibleId};

      await createDistributionCodeUser({
        "userId": newOwnerId,
        "distributionCodeId": distributionCodeId,
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
        "collectibleReceived": collectibleReceivedJson
      }, _appAuthProvider);

      await updateMissionProgress(
        userId: newOwnerId, // The user receiving the collectible
        collectibleId: collectibleId,
        operation: MissionProgressOperation.increment,
        context: context,
      );
      await updateMissionProgress(
        userId: giverId, // The user giving the collectible
        collectibleId: collectibleId,
        operation: MissionProgressOperation.decrement,
        context: context,
      );

      await updateUserCollectibleByUserCollectibleId({
        "userCollectibleId": userCollectibleId,
        "ownerId": newOwnerId,
        "previousOwnerId": giverId,
        "lastTransferredDt": DateTime.now().toIso8601String(),
      }, _appAuthProvider);

      _setState(
          isLoading: false,
          loadingMessage: "dist_model_completetransfer_success");
      return {'collectibleId': collectibleId, 'giverId': giverId};
    } catch (e) {
      _setState(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> redeemMissionReward(
      {required String missionDistributionId,
      required BuildContext context}) async {
    _setState(
        isLoading: true, loadingMessage: "dist_model_redeemreward_claiming");
    final String? userId = userModel.currentUser?['userId']?.toString();

    try {
      if (userId == null) throw Exception("dist_model_redeemreward_nouser");

      final distribution = await getDistributionByDistributionId(
          missionDistributionId, _appAuthProvider);
      if (distribution == null) {
        throw Exception("dist_model_reward_nodetails");
      }

      // Apply the same isRandom logic for mission rewards
      List<dynamic> collectiblePool = [];
      final bool isRandom = distribution['isRandom'] ?? false;

      if (isRandom) {
        final collectionId = distribution['collectionId']?.toString();
        if (collectionId == null) {
          throw Exception("dist_model_reward_nocollection");
        }
        final result =
            await getCollectiblesByCollectionId(collectionId, _appAuthProvider);
        if (result is List) {
          collectiblePool = result;
        }
      } else {
        final result = await getDistributionCollectiblesByDistributionId(
            missionDistributionId, _appAuthProvider);
        if (result is List) {
          collectiblePool = result;
        }
      }

      if (collectiblePool.isEmpty) {
        throw Exception("dist_model_redeemreward_norewards");
      }

      Map<String, dynamic> collectibleForMinting;
      String collectibleToAwardId;

      final randomItemFromPool =
          collectiblePool[Random().nextInt(collectiblePool.length)];

      if (isRandom) {
        collectibleForMinting = randomItemFromPool;
        collectibleToAwardId =
            collectibleForMinting['collectibleId'].toString();
      } else {
        collectibleToAwardId = randomItemFromPool['collectibleId'].toString();
        dynamic fetchedCollectible = await getCollectibleByCollectibleId(
            collectibleToAwardId, _appAuthProvider);
        if (fetchedCollectible == null) {
          throw Exception("dist_model_reward_get_collectible_fail");
        }
        if (fetchedCollectible is List) {
          if (fetchedCollectible.isEmpty) {
            throw Exception("dist_model_reward_get_collectible_fail");
          }
          collectibleForMinting = fetchedCollectible.first;
        } else {
          collectibleForMinting = fetchedCollectible;
        }
      }

      final allUserCollectibles =
          await getUserCollectiblesByOwnerId(userId, _appAuthProvider);
      final int? newMint =
          generateRandomMint(collectibleForMinting, allUserCollectibles);
      if (newMint == null) {
        throw Exception("dist_model_no_mints");
      }
      final newCode = await createDistributionCode({
        "distributionId": missionDistributionId,
        "code":
            "MISSION-${missionDistributionId}-${userId}-${DateTime.now().millisecondsSinceEpoch}",
        "isMultiUse": false,
      }, _appAuthProvider);

      final collectibleReceivedJson = {'collectibleId': collectibleToAwardId};

      await createDistributionCodeUser({
        "userId": userId,
        "distributionCodeId": newCode['distributionCodeId'],
        "redeemed": true,
        "redeemedDate": DateTime.now().toIso8601String(),
        "collectibleReceived": collectibleReceivedJson
      }, _appAuthProvider);

      await updateMissionProgress(
        userId: userId,
        collectibleId: collectibleToAwardId,
        operation: MissionProgressOperation.increment,
        context: context,
      );

      await createUserCollectible(
          userId, collectibleToAwardId, newMint, _appAuthProvider);

      _setState(
          isLoading: false, loadingMessage: "dist_model_redeemreward_success");
      return true;
    } catch (e) {
      final errorKey = e.toString().replaceFirst('Exception: ', '');
      print("Failed to claim reward: $errorKey");
      _setState(isLoading: false, error: errorKey);
      return false;
    }
  }

  // --- START: NEW DEBUG FUNCTION ---
  /// A temporary function to reset a specific test code for debugging purposes.
  Future<void> resetTestCode() async {
    print("--- DEBUG: Attempting to reset test code status ---");
    try {
      final body = {
        "distributionCodeUserId": "1",
        "redeemed": false,
        "redeemedDate": null,
        "collectibleReceived": null,
      };

      // --- START: THE FIX ---
      // Log the exact body being sent to the API.
      print("--- DEBUG: Sending PATCH request with body: $body ---");
      // --- END: THE FIX ---

      await updateDistributionCodeUserByDistributionCodeUserId(
          body, _appAuthProvider);
      print("--- DEBUG: Test code reset request sent successfully ---");
    } catch (e) {
      print("--- DEBUG: Failed to reset test code in model: $e ---");
      _errorMessage = "Failed to reset test code: $e";
      notifyListeners();
    }
  }
}
