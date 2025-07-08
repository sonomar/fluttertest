import './mission_view.dart';
import 'package:flutter/material.dart';

Map<String, dynamic>? getLatestCollectible(
    List<dynamic> collectibles, List<dynamic> userCollectibles) {
  dynamic mostRecentUserCollectible;
  DateTime? latestUpdateTime;

  if (userCollectibles.isEmpty) {
    return null; // No user collectibles to process
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
    return null; // No user collectible with a valid date was found
  }

  // 2. Find the corresponding Collectible using collectibleId
  final String? mostRecentCollectibleId =
      mostRecentUserCollectible['collectibleId']?.toString();

  if (mostRecentCollectibleId == null) {
    return null;
  }
  dynamic correspondingCollectible;
  try {
    if (collectibles.isNotEmpty && collectibles.every((c) => c is Map)) {
      correspondingCollectible = collectibles.firstWhere(
        (collectible) =>
            collectible != null &&
            collectible['collectibleId']?.toString() == mostRecentCollectibleId,
        orElse: () => null, // Return null if no matching collectible is found
      );
    } else {
      print(
          'WARNING: Collectibles list is empty or contains non-Map elements.');
      return null;
    }
  } catch (e) {
    return null;
  }

  if (correspondingCollectible == null) {
    return null;
  }
  return correspondingCollectible;
}

Widget getLatestActiveMission(
    context, List<dynamic> missions, List<dynamic> missionUsers,
    {bool isViewer = false}) {
  if (missions.isEmpty || missionUsers.isEmpty) {
    return const SizedBox.shrink();
  }
  // The missions.dart screen already sorts the list to bring claimable missions to the top.
  // We can iterate through the pre-sorted list to find the first valid mission to display.
  for (var mission in missions) {
    if (mission == null || mission['missionId'] == null) {
      continue;
    }
    // Find the corresponding user progress for this mission.
    final correspondingMissionUser = missionUsers.firstWhere(
      (mu) => mu != null && mu['missionId'] == mission['missionId'],
      orElse: () => null,
    );
    if (correspondingMissionUser == null) {
      continue;
    }
    // Check if the mission is active and NOT yet completed.
    final bool isActive = mission['active'] ?? true;
    final bool isCompleted = correspondingMissionUser['completed'] ?? false;
    if (isActive && !isCompleted) {
      // We found our highest-priority active mission. Display it and stop searching.
      return isViewer
          ? viewMissionWidget(context, mission, correspondingMissionUser)
          : homeMissionWidget(context, mission, correspondingMissionUser);
    }
  }

  // If the loop completes, no active, non-completed missions were found.
  return const SizedBox.shrink();
}

Widget listMissions(context, getMissions, getMissionUsers) {
  if (getMissions.isEmpty) {
    return const SizedBox.shrink();
  }

  final List<Widget> validMissionWidgets = [];

  // Iterate through all missions to find their corresponding user progress.
  for (var mission in getMissions) {
    final correspondingMissionUser = getMissionUsers.firstWhere(
      (missionUser) =>
          missionUser['missionId'].toString() ==
          mission['missionId'].toString(),
      orElse: () => null,
    );
    if (correspondingMissionUser != null &&
        (correspondingMissionUser['completed'] == false ||
            correspondingMissionUser['completed'] == null)) {
      validMissionWidgets.add(
        Container(
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: missionWidget(context, mission, correspondingMissionUser),
        ),
      );
    }
    // Stop after finding two missions to display.
    if (validMissionWidgets.length >= 2) {
      break;
    }
  }

  if (validMissionWidgets.isEmpty) {
    return const SizedBox.shrink();
  } else {
    return Column(
      children: validMissionWidgets,
    );
  }
}
