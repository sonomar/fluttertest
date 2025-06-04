import './mission_view.dart';
import 'package:flutter/material.dart';

dynamic getLatestCollectible(
    List<dynamic> collectibles, List<dynamic> userCollectibles) {
  dynamic mostRecentUserCollectible;
  DateTime? latestUpdateTime;

  if (userCollectibles.isEmpty) {
    return 'not found 1'; // No user collectibles to process
  }
  for (var userCollectible in userCollectibles) {
    // Basic null checks for safe access
    if (userCollectible == null || userCollectible['updatedDt'] == null) {
      print(
          'WARNING: Skipping invalid userCollectible (null or missing updatedDt).');
      continue;
    }

    try {
      final String updatedDtString = userCollectible['updatedDt'] as String;
      final DateTime currentUpdateTime = DateTime.parse(updatedDtString);

      if (latestUpdateTime == null ||
          currentUpdateTime.isAfter(latestUpdateTime)) {
        latestUpdateTime = currentUpdateTime;
        mostRecentUserCollectible = userCollectible;
      }
    } catch (e) {
      print(
          'WARNING: Could not parse updatedDt for userCollectible: ${userCollectible['updatedDt']}. Error: $e');
      // Continue to next collectible if date parsing fails
    }
  }
  if (mostRecentUserCollectible == null) {
    return 'not found 2'; // No user collectible with a valid date was found
  }

  // 2. Find the corresponding Collectible using collectibleId
  final String? mostRecentCollectibleId =
      mostRecentUserCollectible['collectibleId']?.toString();

  if (mostRecentCollectibleId == null) {
    return 'not found 3';
  }

  // --- FIX IS HERE ---
  // Change the type from List<dynamic> to dynamic (or Map<String, dynamic>?)
  dynamic correspondingCollectible; // Changed from List<dynamic>
  try {
    correspondingCollectible = collectibles.firstWhere(
      (collectible) =>
          collectible != null &&
          collectible['collectibleId']?.toString() == mostRecentCollectibleId,
      orElse: () => null, // Return null if no matching collectible is found
    );
  } catch (e) {
    // This catch is for cases where 'collectibles' itself is somehow malformed
    // (e.g., if it's not actually an Iterable or if elements are non-Maps when expected)
    return 'not found 4';
  }

  if (correspondingCollectible == null) {
    return 'not found 5';
  }

  // 3. Return the URL for the embed in the related collectible
  return correspondingCollectible;
}

Widget getLatestActiveMission(
    context, missions, missionUsers, latestCollectible,
    {bool isViewer = false}) {
  if (latestCollectible == 'not found' ||
      latestCollectible == null ||
      latestCollectible['collectionId'] == null) {
    return const SizedBox.shrink(); // Return nothing if no basis for filtering
  }
  final dynamic latestCollectibleCollectionId =
      latestCollectible['collectionId'];
  if (missions.isEmpty) {
    return const SizedBox.shrink(); // Return nothing if no missions to check
  }
  for (var mission in missions) {
    // 1. Basic null checks for mission and its ID, goal, and collectionId
    if (mission == null ||
        mission['missionId'] == null ||
        mission['goal'] == null ||
        mission['collectionId'] == null) {
      continue;
    }
    final String missionId = mission['missionId'].toString();
    final num missionGoal = mission['goal'] as num;
    final dynamic missionCollectionId = mission['collectionId'];
    // NEW CHECK: Compare collectionId
    if (missionCollectionId != latestCollectibleCollectionId) {
      continue; // Skip if collectionId does not match
    }
    if (mission['active'] != null && mission['active'] == false) {
      continue;
    }
    dynamic correspondingMissionUser;
    try {
      correspondingMissionUser = missionUsers.firstWhere(
        (mu) => mu != null && mu['missionId']?.toString() == missionId,
        orElse: () => null,
      );
    } catch (e) {
      continue;
    }
    if (correspondingMissionUser == null ||
        correspondingMissionUser['progress'] == null) {
      continue;
    }

    final num userProgress = correspondingMissionUser['progress'] as num;
    if (userProgress != missionGoal) {
      // If all conditions are met, return the missionWidget
      return isViewer
          ? viewMissionWidget(context, mission, correspondingMissionUser)
          : homeMissionWidget(context, mission, correspondingMissionUser);
    } else {
      print(
          'DEBUG: Mission ID $missionId is completed (progress == goal). Skipping.');
    }
  }

  // If the loop finishes, no such mission was found, return an empty widget
  return const SizedBox.shrink();
}

Widget listMissions(context, getMissions, getMissionUsers) {
  if (getMissions.isEmpty) {
    return const SizedBox.shrink(); // No missions available
  }

  // Create a list to hold the mission widgets that meet the criteria
  final List<Widget> validMissionWidgets = [];

  // Iterate through userMissions to find corresponding missions and apply conditions
  for (var missionUser in getMissionUsers) {
    // Find the corresponding mission from the getMissions list
    final correspondingMission = getMissions.firstWhere(
      (mission) =>
          mission['missionId'].toString() ==
          missionUser['missionId'].toString(),
      orElse: () => null, // Return null if no matching mission is found
    );

    // Check if a corresponding mission was found and if the goal is not met
    if (correspondingMission != null &&
        correspondingMission['goal'] != null &&
        missionUser['progress'] != null &&
        (correspondingMission['goal'] as num) !=
            (missionUser['progress'] as num)) {
      // If conditions are met, create the mission widget and add it to our list
      validMissionWidgets.add(
        Container(
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: 20,
          ),
          child: missionWidget(context, correspondingMission, missionUser),
        ),
      );

      // IMPORTANT: If we already have 2 valid mission widgets, stop adding more.
      if (validMissionWidgets.length >= 2) {
        break; // Exit the loop early
      }
    }
  }

  // Return a Column containing only the first two valid mission widgets
  if (validMissionWidgets.isEmpty) {
    return const SizedBox.shrink(); // No missions met the criteria or only 0-1
  } else {
    // Take a sublist of the first two items if there are more than two, otherwise take all.
    return Column(
      children: validMissionWidgets.take(2).toList(),
    );
  }
}
