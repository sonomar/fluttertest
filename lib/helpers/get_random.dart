import 'dart:math';

/// Generates a unique, random mint number for a given collectible.
///
/// This function is designed to work with Map<String, dynamic> objects from your API.
/// It finds all mints a user already owns for a collectible and selects a new
/// random one from the remaining available mints up to the collectible's circulation.
///
/// [collectible]: The template map for the collectible being awarded.
/// [userCollectibles]: The full list of the user's currently owned collectibles.
int? generateRandomMint(
    Map<String, dynamic>? collectible, List<dynamic>? userCollectibles) {
  // 1. Validate the input data.
  if (collectible == null ||
      collectible['collectibleId'] == null ||
      collectible['circulation'] == null) {
    print("Error: Provided collectible data is invalid for mint generation.");
    return null; // Return null if collectible data is incomplete.
  }

  final String collectibleId = collectible['collectibleId'].toString();
  final int circulation = collectible['circulation'] as int;

  if (circulation <= 0) {
    print("Error: Collectible ID $collectibleId has no circulation.");
    return null; // No mints are possible if circulation is 0 or less.
  }

  // 2. Collect a set of all mints the user already has for this specific collectible.
  final Set<int> usedMints = {};
  if (userCollectibles != null) {
    for (var uc in userCollectibles) {
      if (uc is Map &&
          uc['collectibleId']?.toString() == collectibleId &&
          uc['mint'] != null) {
        // Ensure mint is treated as an integer.
        usedMints.add(int.parse(uc['mint'].toString()));
      }
    }
  }

  // 3. Create a list of all possible mints that are not already used.
  final List<int> availableMints = [];
  for (int i = 1; i <= circulation; i++) {
    if (!usedMints.contains(i)) {
      availableMints.add(i);
    }
  }

  // 4. If no mints are available, return null to indicate the collectible is "sold out".
  if (availableMints.isEmpty) {
    print("Warning: No available mints for collectible ID $collectibleId.");
    return null;
  }

  // 5. Return a random mint from the list of available ones.
  final random = Random();
  final int randomIndex = random.nextInt(availableMints.length);
  return availableMints[randomIndex];
}
