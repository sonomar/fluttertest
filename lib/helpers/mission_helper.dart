import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deins_app/models/mission_model.dart';
import 'package:deins_app/models/collectible_model.dart';

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

  // Find the collectible's template to get its collectionId
  final collectibleTemplate =
      collectibleModel.collectionCollectibles.firstWhere(
    (c) => c['collectibleId'].toString() == collectibleId,
    orElse: () => null,
  );
  if (collectibleTemplate == null ||
      collectibleTemplate['collectionId'] == null) {
    print(
        "MissionHelper: Could not find collectible template or its collection ID.");
    return;
  }
  final dynamic collectionId = collectibleTemplate['collectionId'];
  final relevantMissions = missionModel.missions
      .where((m) => m['collectionId'].toString() == collectionId.toString())
      .toList();
  if (relevantMissions.isEmpty) {
    print("MissionHelper: No missions found for collection ID $collectionId.");
    return;
  }

  for (var mission in relevantMissions) {
    final missionUser = missionModel.missionUsers.firstWhere(
      (mu) =>
          mu['userId'].toString() == userId &&
          mu['missionId'] == mission['missionId'],
      orElse: () => null,
    );

    if (missionUser == null) continue;
    if (missionUser['completed'] == true) {
      print(
          "MissionHelper: Mission ${mission['missionId']} is already complete. No update needed.");
      continue;
    }

    // Calculate new progress
    int currentProgress = missionUser['progress'] as int;
    int newProgress = (operation == MissionProgressOperation.increment)
        ? currentProgress + 1
        : currentProgress - 1;

    // Ensure progress doesn't go below zero
    if (newProgress < 0) newProgress = 0;

    // Prepare body and call API to update MissionUser progress
    await missionModel.updateMissionProgress(missionUser, newProgress);
  }
}
