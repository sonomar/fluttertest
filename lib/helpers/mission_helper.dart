import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deins_app/models/mission_model.dart';
import 'package:deins_app/models/collectible_model.dart';

// An enum to make the operation clear
enum MissionProgressOperation { increment, decrement }

Future<void> updateMissionProgress({
  required String userId,
  required String collectibleId,
  required MissionProgressOperation operation,
  required BuildContext context,
}) async {
  // Use read to get providers without listening
  final missionModel = context.read<MissionModel>();
  final collectibleModel = context.read<CollectibleModel>();
  await collectibleModel.loadCollectibles();
  final List<dynamic> userCollectibles = collectibleModel.userCollectibles;
  bool shouldUpdate = false;

  if (operation == MissionProgressOperation.increment) {
    // Check if this will be the FIRST instance of this collectible.
    final count = userCollectibles
        .where((uc) => uc['collectibleId'].toString() == collectibleId)
        .length;
    if (count == 0) {
      shouldUpdate = true;
    }
  } else if (operation == MissionProgressOperation.decrement) {
    // Check if this is the LAST instance of this collectible.
    final count = userCollectibles
        .where((uc) => uc['collectibleId'].toString() == collectibleId)
        .length;
    if (count == 1) {
      shouldUpdate = true;
    }
  }

  if (!shouldUpdate) {
    print(
        "MissionHelper: Collectible change is not unique. Skipping progress update.");
    return;
  }

  print(
      "MissionHelper: Collectible change is unique. Proceeding to find relevant missions.");

  // Find the collectible's template to get its collectionId
  dynamic collectibleTemplate;
  try {
    collectibleTemplate = collectibleModel.collectionCollectibles.firstWhere(
      (c) => c['collectibleId'].toString() == collectibleId,
    );
  } on StateError {
    // This error is thrown if no matching collectible is found.
    collectibleTemplate = null;
  }
  if (collectibleTemplate == null ||
      collectibleTemplate['collectionId'] == null) {
    print(
        "MissionHelper: Could not find collectible template or its collection ID.");
    return;
  }
  final dynamic collectionId = collectibleTemplate['collectionId'];
  print("Found collectible: ${collectibleTemplate['name']}");
  print(
      "Its collection ID is: $collectionId (Type: ${collectionId.runtimeType})");
  print("Available missions in model: ${missionModel.missions.length}");
  for (var m in missionModel.missions) {
    print(
        "  - Mission '${m['title']}' has collectionId: ${m['collectionId']} (Type: ${m['collectionId'].runtimeType})");
  }
  final relevantMissions = missionModel.missions
      .where((m) => m['collectionId'].toString() == collectionId.toString())
      .toList();
  if (relevantMissions.isEmpty) {
    print("MissionHelper: No missions found for collection ID $collectionId.");
    return;
  }

  print(
      "Found ${relevantMissions.length} relevant mission(s). Proceeding to update progress.");
  for (var mission in relevantMissions) {
    dynamic missionUser;
    try {
      missionUser = missionModel.missionUsers.firstWhere(
        (mu) =>
            mu['userId'].toString() == userId &&
            mu['missionId'] == mission['missionId'],
      );
    } on StateError {
      missionUser = null;
    }

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

    final int missionGoal = mission['goal'] as int;
    if (newProgress > missionGoal) {
      newProgress = missionGoal;
    }
    // Prepare body and call API to update MissionUser progress
    await missionModel.updateMissionProgress(missionUser, newProgress);
  }
}
