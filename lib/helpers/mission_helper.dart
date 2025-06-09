import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kloppocar_app/models/mission_model.dart';
import 'package:kloppocar_app/models/collectible_model.dart';
import 'package:kloppocar_app/models/app_auth_provider.dart';
import 'package:kloppocar_app/api/mission_user.dart';

// An enum to make the operation clear
enum MissionProgressOperation { increment, decrement }

/// A helper function to update a user's mission progress based on collectible actions.
///
/// This function finds missions related to a collectible's collection, updates
/// the user's progress, and handles completion status.
Future<void> updateMissionProgress({
  required String userId,
  required String collectibleId,
  required MissionProgressOperation operation,
  required BuildContext context,
}) async {
  // Use read to get providers without listening
  final missionModel = context.read<MissionModel>();
  final collectibleModel = context.read<CollectibleModel>();
  final authProvider = context.read<AppAuthProvider>();

  // 1. Find the collectible's template to get its collectionId
  final collectibleTemplate =
      collectibleModel.collectionCollectibles.firstWhere(
    (c) => c['collectibleId'].toString() == collectibleId,
    orElse: () => null,
  );

  print('missionHelper: collectibleTemplate: $collectibleTemplate');
  if (collectibleTemplate == null ||
      collectibleTemplate['collectionId'] == null) {
    print(
        "MissionHelper: Could not find collectible template or its collection ID.");
    return;
  }
  final dynamic collectionId = collectibleTemplate['collectionId'];

  // 2. Find all missions associated with that collectionId
  final relevantMissions = missionModel.missions
      .where((m) => m['collectionId'].toString() == collectionId.toString())
      .toList();
  print('missionHelper: relevantMissions: $relevantMissions');
  if (relevantMissions.isEmpty) {
    print("MissionHelper: No missions found for collection ID $collectionId.");
    return;
  }

  // 3. Loop through each relevant mission and update the user's progress
  for (var mission in relevantMissions) {
    print('missionInstance: mission: $mission');
    final missionUser = missionModel.missionUsers.firstWhere(
      (mu) =>
          mu['userId'].toString() == userId &&
          mu['missionId'] == mission['missionId'],
      orElse: () => null,
    );

    if (missionUser == null) continue; // User is not part of this mission

    // IMPORTANT RULE: If mission is already complete, do nothing.
    if (missionUser['completed'] == true) {
      print(
          "MissionHelper: Mission ${mission['missionId']} is already complete. No update needed.");
      continue;
    }

    // 4. Calculate new progress
    int currentProgress = missionUser['progress'] as int;
    int newProgress = (operation == MissionProgressOperation.increment)
        ? currentProgress + 1
        : currentProgress - 1;

    // Ensure progress doesn't go below zero
    if (newProgress < 0) newProgress = 0;

    // 5. Check for completion
    final int goal = mission['goal'] as int;
    bool isNowCompleted = (newProgress >= goal);

    // 6. Prepare body and call API to update MissionUser
    try {
      final body = {
        "missionUserId": missionUser['missionUserId'],
        "progress": newProgress,
        "completed": isNowCompleted,
      };
      await updateMissionUserByMissionUserId(body, authProvider);
      print(
          "MissionHelper: Successfully updated progress for mission ${mission['missionId']}.");
    } catch (e) {
      print(
          "MissionHelper: Failed to update mission progress via API. Error: $e");
    }
  }

  // 7. Refresh the mission data in the app to reflect changes
  await missionModel.loadMissions();
}
